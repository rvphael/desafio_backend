defmodule DesafioBackend.TradingTest do
  use DesafioBackend.DataCase, async: true

  alias DesafioBackend.Factory
  alias DesafioBackend.Trading

  describe "get_trade_summary/2" do
    @valid_ticker "PETR4"
    @invalid_ticker "INVALID123"
    @trade_date ~D[2024-02-08]

    setup do
      trades = [
        insert(:trade,
          codigo_instrumento: @valid_ticker,
          data_negocio: @trade_date,
          preco_negocio: 100.0,
          quantidade_negociada: 100
        ),
        insert(:trade,
          codigo_instrumento: @valid_ticker,
          data_negocio: @trade_date,
          preco_negocio: 150.0,
          quantidade_negociada: 200
        )
      ]

      {:ok, trades: trades}
    end

    test "returns the correct summary for a given ticker and no trade_date", %{trades: trades} do
      summary = Trading.get_trade_summary(@valid_ticker)

      assert summary.max_range_value == 150.0
      assert summary.max_daily_volume == 300
    end

    test "returns the correct summary for a given ticker and trade_date", %{trades: trades} do
      summary = Trading.get_trade_summary(@valid_ticker, @trade_date)

      assert summary.max_range_value == 150.0
      assert summary.max_daily_volume == 300
    end

    test "returns zero values for an invalid ticker" do
      summary = Trading.get_trade_summary(@invalid_ticker)

      assert summary.max_range_value == 0
      assert summary.max_daily_volume == 0
    end

    test "returns zero values for a valid ticker but future trade_date" do
      future_date = Date.add(@trade_date, 10)
      summary = Trading.get_trade_summary(@valid_ticker, future_date)

      assert summary.max_range_value == 0
      assert summary.max_daily_volume == 0
    end
  end
end
