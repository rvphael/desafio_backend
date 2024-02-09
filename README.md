# Desafio Backend - B3 Data Processor

Este projeto oferece uma solução eficiente para o processamento e análise de grandes volumes de dados de negociações da B3. Utilizando o Phoenix Framework e Elixir, a aplicação baixa dados históricos de negociações, persiste-os em um banco de dados PostgreSQL e expõe uma API para consulta desses dados com agregações específicas.

## Estrutura do Projeto

A estrutura do projeto segue a organização padrão do Phoenix, com diretórios específicos para o código da aplicação (`lib`), configurações (`config`), testes (`test`), e um script personalizado para processamento e importação dos dados (`process_and_import.sh`).

## Configuração Inicial

### Pré-requisitos

- Elixir 1.14
- Erlang OTP 26
- PostgreSQL 14
- Phoenix Framework

### Configurando o Ambiente de Desenvolvimento

1. **Configure o banco de dados:** Atualize as variáveis de ambiente no arquivo `.env` com suas credenciais de banco de dados.

```bash
cp .env_example .env
```

2. **Prepare o PostgreSQL:** Para o funcionamento do script de processamento e importação de dados, certifique-se de configurar o método de autenticação do PostgreSQL local para `md5` editando o arquivo `pg_hba.conf` e reiniciando o serviço do PostgreSQL.

3. **Instale as dependências do projeto, crie e migre o banco de dados**

```bash
mix setup
```

### Processamento e Importação de Dados

Execute o script `process_and_import.sh` para baixar, processar e importar os dados dos últimos 7 dias úteis de negociações da B3.

```bash
./process_and_import.sh
```

### Executando a Aplicação

Inicie o servidor Phoenix com o seguinte comando:

```bash
mix phx.server
```

A aplicação estará disponível em http://localhost:4000.

### Utilizando a API

- Consultar dados por ticker:

```
GET /api/trades?ticker=PETR4
```

- Consultar dados por ticker e data:

```
GET /api/trades?ticker=PETR4&data_negocio=2024-02-08
```

### Respostas da API

- Sucesso:

```json
{
  "ticker": "PETR4",
  "max_daily_volume": 61629200,
  "max_range_value": 42.45
}
```

- Ticker ou DataNegocio não encontrados:

```json
{
  "errors": {
    "detail": "Not Found"
  }
}
```

### Testes

Para executar os testes da aplicação, use:

```bash
mix test
```
