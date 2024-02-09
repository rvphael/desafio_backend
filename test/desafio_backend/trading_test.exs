defmodule DesafioBackend.TradingTest do
  use DesafioBackend.DataCase, async: true

  alias DesafioBackend.Trading

  describe "get_trade_summary/2" do
    @valid_ticker "PETR4"
    @invalid_ticker "INVALID123"
    @trade_date ~D[2024-02-08]

    setup do
      insert(:trade,
        codigo_instrumento: @valid_ticker,
        data_negocio: @trade_date,
        preco_negocio: 100.0,
        quantidade_negociada: 100
      )

      insert(:trade,
        codigo_instrumento: @valid_ticker,
        data_negocio: @trade_date,
        preco_negocio: 150.0,
        quantidade_negociada: 200
      )

      :ok
    end

    test "returns the correct summary for a given ticker and no trade_date" do
      {:ok, summary} = Trading.get_trade_summary(@valid_ticker)

      assert summary.max_range_value == 150.0
      assert summary.max_daily_volume == 300
    end

    test "returns the correct summary for a given ticker and trade_date" do
      {:ok, summary} = Trading.get_trade_summary(@valid_ticker, @trade_date)

      assert summary.max_range_value == 150.0
      assert summary.max_daily_volume == 300
    end

    test "returns not found for an invalid ticker" do
      assert {:error, :not_found} = Trading.get_trade_summary(@invalid_ticker)
    end

    test "returns not found for a valid ticker but future trade_date" do
      future_date = Date.add(@trade_date, 10)
      assert {:error, :not_found} = Trading.get_trade_summary(@valid_ticker, future_date)
    end
  end
end
