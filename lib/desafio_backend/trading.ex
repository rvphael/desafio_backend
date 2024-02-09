defmodule DesafioBackend.Trading do
  @moduledoc """
  Module responsible for providing functionalities related to trades.
  """
  import Ecto.Query, warn: false

  alias DesafioBackend.Repo

  @doc """
  Returns the highest trading value (max_range_value) and
  the highest daily trading volume (max_daily_volume)
  for a given ticker and optionally filtered by date.
  """
  @spec get_trade_summary(String.t(), Date.t() | nil) :: {:ok, map} | {:error, atom}
  def get_trade_summary(ticker, trade_date \\ nil) do
    with {:ok, max_range_value} <- max_range_value(ticker, trade_date),
         max_daily_volume <- max_daily_volume(ticker, trade_date) do
      {:ok,
       %{
         ticker: ticker,
         max_range_value: max_range_value || 0,
         max_daily_volume: max_daily_volume || 0
       }}
    end
  end

  defp max_range_value(ticker, trade_date) do
    sql =
      """
      SELECT MAX(preco_negocio) FROM trades
      WHERE codigo_instrumento = $1
      """ <> cond_sql_date_filter(trade_date)

    case Repo.query(sql, [ticker] ++ cond_sql_params(trade_date)) do
      {:ok, %{rows: [row]}} ->
        case List.first(row) do
          nil -> {:error, :not_found}
          value -> {:ok, value}
        end

      _ ->
        {:error, :not_found}
    end
  end

  defp max_daily_volume(ticker, trade_date) do
    sql =
      """
      SELECT data_negocio, SUM(quantidade_negociada) as volume
      FROM trades
      WHERE codigo_instrumento = $1
      """ <>
        cond_sql_date_filter(trade_date) <>
        """
        GROUP BY data_negocio
        ORDER BY volume DESC
        LIMIT 1
        """

    result = Repo.query(sql, [ticker] ++ cond_sql_params(trade_date))

    case result do
      {:ok, %{rows: []}} ->
        nil

      {:ok, %{rows: [row]}} ->
        List.last(row)

      _ ->
        nil
    end
  end

  defp cond_sql_date_filter(nil), do: ""
  defp cond_sql_date_filter(_), do: "AND data_negocio = $2"

  defp cond_sql_params(nil), do: []
  defp cond_sql_params(trade_date), do: [trade_date]
end
