defmodule DesafioBackendWeb.TradeController do
  use DesafioBackendWeb, :controller

  alias DesafioBackend.Trading
  alias DesafioBackend.Trading.Trade

  action_fallback DesafioBackendWeb.FallbackController

  def index(conn, _params) do
    trades = Trading.list_trades()
    render(conn, :index, trades: trades)
  end

  def create(conn, %{"trade" => trade_params}) do
    with {:ok, %Trade{} = trade} <- Trading.create_trade(trade_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/trades/#{trade}")
      |> render(:show, trade: trade)
    end
  end

  def show(conn, %{"id" => id}) do
    trade = Trading.get_trade!(id)
    render(conn, :show, trade: trade)
  end

  def update(conn, %{"id" => id, "trade" => trade_params}) do
    trade = Trading.get_trade!(id)

    with {:ok, %Trade{} = trade} <- Trading.update_trade(trade, trade_params) do
      render(conn, :show, trade: trade)
    end
  end

  def delete(conn, %{"id" => id}) do
    trade = Trading.get_trade!(id)

    with {:ok, %Trade{}} <- Trading.delete_trade(trade) do
      send_resp(conn, :no_content, "")
    end
  end
end
