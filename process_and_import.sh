#!/bin/bash

# Configurações iniciais: define o banco de dados, usuário, senha e diretórios de trabalho.
export $(cat .env | xargs)
BASE_URL=https://arquivos.b3.com.br/apinegocios/tickercsv/
TEMP_DIR="temp"
EXTRACTED_DIR="${TEMP_DIR}/extracted"
FORMATTED_DIR="${EXTRACTED_DIR}/formatted"

# Cria os diretórios necessários para armazenar os arquivos temporários, extraídos e formatados.
mkdir -p "$TEMP_DIR"
mkdir -p "$EXTRACTED_DIR"
mkdir -p "$FORMATTED_DIR"

# Função para baixar arquivos dos últimos 7 dias úteis.
download_files() {
    for day in $(get_last_7_business_days); do
        local url="${BASE_URL}${day}.zip"
        echo "Downloading: $url"
        curl -Ls --create-dirs -o "${TEMP_DIR}/${day}.zip" "$url"
    done
}

# Função para extrair os arquivos baixados.
extract_files() {
    find "$TEMP_DIR" -name '*.zip' -exec unzip -o -d "$EXTRACTED_DIR" '{}' \;
}

# Função para formatar os arquivos extraídos, ajustando o formato dos dados.
format_files() {
    find "$EXTRACTED_DIR" -name '*.txt' | while read -r txt_file; do
        local base_name=$(basename "$txt_file" .txt)
        awk -F';' 'NR > 1 {gsub(",", ".", $4); print $6, $9, $2, $4, $5}' OFS=';' "$txt_file" > "${FORMATTED_DIR}/${base_name}_formatted.csv"
    done
}

# Função para inserir os dados formatados no banco de dados.
insert_data() {
    find "$FORMATTED_DIR" -name '*.csv' | while read -r csv_file; do
        PGPASSWORD=$PASSWORD psql -U "$USER" -d "$DATABASE" -c "\COPY trades(hora_fechamento, data_negocio, codigo_instrumento, preco_negocio, quantidade_negociada) FROM '$csv_file' WITH (FORMAT csv, DELIMITER ';', HEADER false);"
        if [ $? -eq 0 ]; then
            echo "Dados inseridos com sucesso de $csv_file"
        else
            echo "Falha ao inserir dados de $csv_file"
        fi
    done
}

# Função para criar partições para os últimos 7 dias úteis.
create_partitions() {
    echo "Criando partições necessárias..."
    local today=$(date +%Y-%m-%d)

    # Primeiro, garante a criação da partição para o dia atual
    ensure_partition_for_day "$today"

    # Depois, cria partições para os últimos 7 dias úteis
    for day in $(get_last_7_business_days); do
        ensure_partition_for_day "$day"
    done
}

ensure_partition_for_day() {
    local day="$1"
    local partition_name="trades_${day//-/}"
    local start_date="$day"
    local end_date=$(date -I -d "$start_date + 1 day")

    PGPASSWORD=$PASSWORD psql -U "$USER" -d "$DATABASE" -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relname = '$partition_name' AND n.nspname = 'public'
        ) THEN
            EXECUTE format('CREATE TABLE %I PARTITION OF trades FOR VALUES FROM (''%s'') TO (''%s'')', '$partition_name', '$start_date', '$end_date');
            EXECUTE format('ALTER TABLE %I ADD CONSTRAINT %I_pkey PRIMARY KEY (id)', '$partition_name', '$partition_name');
        END IF;
    END
    \$\$;
    "
    if [ $? -eq 0 ]; then
        echo "Partição $partition_name criada ou já existe."
    else
        echo "Falha ao criar partição $partition_name."
    fi
}

refresh_materialized_view() {
    echo "Atualizando view materializada..."
    PGPASSWORD=$PASSWORD psql -U "$USER" -d "$DATABASE" -c "
    REFRESH MATERIALIZED VIEW trade_summary_recent_by_ticker;
    "
    if [ $? -eq 0 ]; then
        echo "View materializada atualizada com sucesso."
    else
        echo "Falha ao atualizar view materializada."
    fi
}

# Função para calcular os últimos 7 dias úteis, excluindo finais de semana.
get_last_7_business_days() {
    local business_days=()
    for i in {1..15}; do
        day=$(date -d "-$i day" +%Y-%m-%d)
        dow=$(date -d "$day" +%u)

        if [ "$dow" -lt 6 ]; then
            business_days+=("$day")
        fi

        if [ ${#business_days[@]} -eq 7 ]; then
            break
        fi
    done

    for day in "${business_days[@]}"; do
        echo "$day"
    done
}

# Executa as funções na ordem necessária para processar os dados.
download_files
extract_files
format_files
create_partitions
insert_data
refresh_materialized_view
