defmodule DesafioBackendWeb.TradeControllerTest do
  use DesafioBackendWeb.ConnCase, async: true

  setup %{conn: conn} do
    trade_date = ~D[2024-02-08]

    setup_trade_data(trade_date)

    insert(:trade,
      codigo_instrumento: "PETR4",
      data_negocio: trade_date,
      preco_negocio: 100.0,
      quantidade_negociada: 100
    )

    insert(:trade,
      codigo_instrumento: "PETR4",
      data_negocio: trade_date,
      preco_negocio: 150.0,
      quantidade_negociada: 200
    )

    refresh_trade_summary_materialized_view()

    conn = put_req_header(conn, "accept", "application/json")

    {:ok, conn: conn}
  end

  describe "GET /trades" do
    test "returns trade summary for a given ticker", %{conn: conn} do
      params = %{"ticker" => "PETR4"}

      expected_summary = %{
        "ticker" => "PETR4",
        "max_range_value" => 150.0,
        "max_daily_volume" => 300
      }

      conn = get(conn, "/api/trades", params)

      assert json_response(conn, 200) == expected_summary
    end

    test "returns trade summary for a given ticker and date", %{
      conn: conn
    } do
      params = %{"ticker" => "PETR4", "data_negocio" => "2024-02-08"}

      expected_summary = %{
        "ticker" => "PETR4",
        "max_range_value" => 150.0,
        "max_daily_volume" => 300
      }

      conn = get(conn, "/api/trades", params)

      assert json_response(conn, 200) == expected_summary
    end

    test "returns not found if no data found for given parameters", %{conn: conn} do
      params = %{"ticker" => "INVALID"}

      conn = get(conn, "/api/trades", params)

      assert json_response(conn, 404) == %{"errors" => %{"detail" => "Not Found"}}
    end
  end
end
