defmodule DesafioBackend.Factory do
  @moduledoc """
  This module defines test helpers for creating
  """

  use ExMachina.Ecto, repo: DesafioBackend.Repo

  alias DesafioBackend.Trading.Trade

  @spec trade_factory() :: %DesafioBackend.Trading.Trade{
          __meta__: Ecto.Schema.Metadata.t(),
          codigo_instrumento: <<_::48>>,
          data_negocio: Date.t(),
          hora_fechamento: <<_::72>>,
          id: nil,
          preco_negocio: float(),
          quantidade_negociada: 42
        }
  def trade_factory do
    %Trade{
      hora_fechamento: "034133920",
      data_negocio: ~D[2024-02-08],
      codigo_instrumento: "XPTO42",
      preco_negocio: 120.5,
      quantidade_negociada: 42
    }
  end
end
