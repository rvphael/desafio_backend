defmodule DesafioBackend.TradingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DesafioBackend.Trading` context.
  """

  @doc """
  Generate a trade.
  """
  def trade_fixture(attrs \\ %{}) do
    {:ok, trade} =
      attrs
      |> Enum.into(%{
        codigo_instrumento: "some codigo_instrumento",
        data_negocio: ~D[2024-02-08],
        hora_fechamento: "some hora_fechamento",
        preco_negocio: 120.5,
        quantidade_negociada: 42
      })
      |> DesafioBackend.Trading.create_trade()

    trade
  end
end
