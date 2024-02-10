defmodule DesafioBackend.Trading do
  @moduledoc """
  Module for trading operations.
  """

  import Ecto.Query, only: [from: 2]
  alias DesafioBackend.Repo
  alias DesafioBackend.Trading.Trade

  @doc """
  Returns the highest trading value (max_range_value) and
  the highest daily trading volume (max_daily_volume)
  for a given ticker and optionally filtered by date.
  """
  @spec get_trade_summary(String.t(), Date.t()) :: {:ok, map()} | {:error, atom()}
  def get_trade_summary(ticker, trade_date \\ nil) do
    max_range_value = get_agg_value(ticker, trade_date, :max, :preco_negocio)
    max_daily_volume = get_agg_value(ticker, trade_date, :sum, :quantidade_negociada)

    build_response(ticker, max_range_value, max_daily_volume)
  end

  defp get_agg_value(ticker, trade_date, agg_func, field),
    do:
      Trade
      |> build_query(ticker, trade_date, agg_func, field)
      |> Repo.one()
      |> handle_result()

  defp build_query(schema, ticker, trade_date, agg_func, field) do
    query =
      from t in schema,
        where: t.codigo_instrumento == ^ticker

    query = apply_date_filter(query, trade_date)
    apply_agg_func(query, agg_func, field)
  end

  defp apply_agg_func(query, :max, field),
    do: from(q in query, select: max(field(q, ^field)))

  defp apply_agg_func(query, :sum, field),
    do: from(q in query, select: sum(field(q, ^field)))

  defp apply_date_filter(query, nil), do: query

  defp apply_date_filter(query, date) do
    from t in query, where: t.data_negocio >= ^date
  end

  defp build_response(_ticker, 0, 0), do: {:error, :not_found}

  defp build_response(ticker, max_range_value, max_daily_volume),
    do:
      {:ok,
       %{
         ticker: ticker,
         max_range_value: max_range_value,
         max_daily_volume: max_daily_volume
       }}

  defp handle_result(nil), do: 0
  defp handle_result(value), do: value
end
