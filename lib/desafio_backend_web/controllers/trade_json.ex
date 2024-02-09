defmodule DesafioBackendWeb.TradeJSON do
  alias DesafioBackend.Trading.Trade

  @doc """
  Renders a list of trades.
  """
  def index(%{trades: trades}) do
    %{data: for(trade <- trades, do: data(trade))}
  end

  @doc """
  Renders a single trade.
  """
  def show(%{trade: trade}) do
    %{data: data(trade)}
  end

  defp data(%Trade{} = trade) do
    %{
      id: trade.id,
      hora_fechamento: trade.hora_fechamento,
      data_negocio: trade.data_negocio,
      codigo_instrumento: trade.codigo_instrumento,
      preco_negocio: trade.preco_negocio,
      quantidade_negociada: trade.quantidade_negociada
    }
  end
end
