defmodule DesafioBackendWeb.TradeController do
  use DesafioBackendWeb, :controller

  action_fallback DesafioBackendWeb.FallbackController

  alias DesafioBackend.Trading

  def show(conn, params) do
    with {:ok, formatted_date} <- format_date(params["data_negocio"]),
         {:ok, trade_summary} <- Trading.get_trade_summary(params["ticker"], formatted_date) do
      send_ok_response(conn, trade_summary)
    else
      {:error, _} = error ->
        send_error_response(error)
    end
  end

  defp format_date(nil), do: {:ok, nil}

  defp format_date(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, "Invalid date format"}
    end
  end

  defp send_ok_response(conn, trade_summary) do
    conn
    |> put_status(:ok)
    |> render("show.json", trade: trade_summary)
  end

  defp send_error_response({:error, "Invalid date format"}),
    do: %{error: "Invalid date format"}

  defp send_error_response({:error, reason}),
    do: {:error, reason}
end
