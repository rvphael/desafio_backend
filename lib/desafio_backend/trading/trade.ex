defmodule DesafioBackend.Trading.Trade do
  @moduledoc """
  Schema for trades.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "trades" do
    field :hora_fechamento, :string
    field :data_negocio, :date
    field :codigo_instrumento, :string
    field :preco_negocio, :float
    field :quantidade_negociada, :integer
  end

  @required_fields ~w(hora_fechamento data_negocio codigo_instrumento preco_negocio quantidade_negociada)a

  @doc false
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
