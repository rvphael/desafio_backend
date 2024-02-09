defmodule DesafioBackendWeb.TradeControllerTest do
  use DesafioBackendWeb.ConnCase

  import DesafioBackend.TradingFixtures

  alias DesafioBackend.Trading.Trade

  @create_attrs %{
    hora_fechamento: "some hora_fechamento",
    data_negocio: ~D[2024-02-08],
    codigo_instrumento: "some codigo_instrumento",
    preco_negocio: 120.5,
    quantidade_negociada: 42
  }
  @update_attrs %{
    hora_fechamento: "some updated hora_fechamento",
    data_negocio: ~D[2024-02-09],
    codigo_instrumento: "some updated codigo_instrumento",
    preco_negocio: 456.7,
    quantidade_negociada: 43
  }
  @invalid_attrs %{hora_fechamento: nil, data_negocio: nil, codigo_instrumento: nil, preco_negocio: nil, quantidade_negociada: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all trades", %{conn: conn} do
      conn = get(conn, ~p"/api/trades")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create trade" do
    test "renders trade when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/trades", trade: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/trades/#{id}")

      assert %{
               "id" => ^id,
               "codigo_instrumento" => "some codigo_instrumento",
               "data_negocio" => "2024-02-08",
               "hora_fechamento" => "some hora_fechamento",
               "preco_negocio" => 120.5,
               "quantidade_negociada" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/trades", trade: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update trade" do
    setup [:create_trade]

    test "renders trade when data is valid", %{conn: conn, trade: %Trade{id: id} = trade} do
      conn = put(conn, ~p"/api/trades/#{trade}", trade: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/trades/#{id}")

      assert %{
               "id" => ^id,
               "codigo_instrumento" => "some updated codigo_instrumento",
               "data_negocio" => "2024-02-09",
               "hora_fechamento" => "some updated hora_fechamento",
               "preco_negocio" => 456.7,
               "quantidade_negociada" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, trade: trade} do
      conn = put(conn, ~p"/api/trades/#{trade}", trade: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete trade" do
    setup [:create_trade]

    test "deletes chosen trade", %{conn: conn, trade: trade} do
      conn = delete(conn, ~p"/api/trades/#{trade}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/trades/#{trade}")
      end
    end
  end

  defp create_trade(_) do
    trade = trade_fixture()
    %{trade: trade}
  end
end
