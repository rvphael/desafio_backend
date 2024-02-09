defmodule DesafioBackend.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :hora_fechamento, :string
      add :data_negocio, :date
      add :codigo_instrumento, :string
      add :preco_negocio, :float
      add :quantidade_negociada, :integer
    end

    create index(:trades, [:codigo_instrumento])
    create index(:trades, [:data_negocio, :codigo_instrumento])
  end
end
