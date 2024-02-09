defmodule DesafioBackendWeb.TradeJSON do
  @moduledoc """
  JSON view for the trade resource.
  """

  @doc """
  Renders a single trade.
  """
  def show(%{trade: trade}) do
    %{
      ticker: trade.ticker,
      max_range_value: trade.max_range_value,
      max_daily_volume: trade.max_daily_volume
    }
  end
end
