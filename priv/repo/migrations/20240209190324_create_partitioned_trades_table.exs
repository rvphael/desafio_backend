defmodule DesafioBackend.Repo.Migrations.CreatePartitionedTradesTable do
  use Ecto.Migration

  def change do
    execute """
    CREATE TABLE trades (
      id BIGSERIAL,
      hora_fechamento TEXT,
      data_negocio DATE NOT NULL,
      codigo_instrumento TEXT NOT NULL,
      preco_negocio FLOAT NOT NULL,
      quantidade_negociada INTEGER NOT NULL
    ) PARTITION BY RANGE (data_negocio);
    """

    create index(:trades, [:codigo_instrumento])
    create index(:trades, [:data_negocio, :codigo_instrumento])
  end
end
