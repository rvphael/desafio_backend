defmodule DesafioBackend.Trading.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "trades" do
    field :hora_fechamento, :string
    field :data_negocio, :date
    field :codigo_instrumento, :string
    field :preco_negocio, :float
    field :quantidade_negociada, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, [:hora_fechamento, :data_negocio, :codigo_instrumento, :preco_negocio, :quantidade_negociada])
    |> validate_required([:hora_fechamento, :data_negocio, :codigo_instrumento, :preco_negocio, :quantidade_negociada])
  end
end
