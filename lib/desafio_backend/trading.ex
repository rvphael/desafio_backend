defmodule DesafioBackend.Trading do
  @moduledoc """
  Module responsible for trading operations.
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
         {:ok, max_daily_volume} <- max_daily_volume(ticker, trade_date) do
      {:ok,
       %{
         ticker: ticker,
         max_range_value: max_range_value || 0,
         max_daily_volume: max_daily_volume || 0
       }}
    else
      _error -> {:error, :not_found}
    end
  end

  defp max_range_value(ticker, nil) do
    query =
      from t in "trade_summary_recent_by_ticker",
        where: t.codigo_instrumento == ^ticker,
        select: max(t.max_preco)

    Repo.one(query)
    |> case do
      nil -> {:error, :not_found}
      value -> {:ok, value}
    end
  end

  defp max_range_value(ticker, trade_date) do
    sql = """
    SELECT MAX(preco_negocio) FROM trades
    WHERE codigo_instrumento = $1 AND data_negocio = $2
    """

    case Repo.query(sql, [ticker, trade_date]) do
      {:ok, %{rows: []}} ->
        {:error, :not_found}

      {:ok, %{rows: [row]}} when row != nil ->
        {:ok, List.first(row)}

      _ ->
        {:error, :not_found}
    end
  end

  defp max_daily_volume(ticker, nil) do
    query =
      from t in "trade_summary_recent_by_ticker",
        where: t.codigo_instrumento == ^ticker,
        select: %{max_daily_volume: t.total_volume}

    Repo.one(query)
    |> case do
      %{max_daily_volume: max_daily_volume} ->
        {:ok, max_daily_volume}

      _ ->
        {:error, :not_found}
    end
  end

  defp max_daily_volume(ticker, trade_date) do
    sql =
      """
      SELECT SUM(quantidade_negociada) as volume
      FROM trades
      WHERE codigo_instrumento = $1 AND data_negocio = $2
      GROUP BY data_negocio
      ORDER BY volume DESC
      LIMIT 1
      """

    Repo.query(sql, [ticker, trade_date])
    |> case do
      {:ok, %{rows: []}} -> nil
      {:ok, %{rows: [row]}} -> {:ok, List.last(row)}
      _ -> nil
    end
  end
end
