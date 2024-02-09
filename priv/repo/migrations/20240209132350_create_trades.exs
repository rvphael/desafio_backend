defmodule DesafioBackend.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :hora_fechamento, :string
      add :data_negocio, :date
      add :codigo_instrumento, :string
      add :preco_negocio, :float
      add :quantidade_negociada, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:trades, [:data_negocio, :codigo_instrumento])
  end
end
