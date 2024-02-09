defmodule DesafioBackend.TradingTest do
  use DesafioBackend.DataCase

  alias DesafioBackend.Trading

  describe "trades" do
    alias DesafioBackend.Trading.Trade

    import DesafioBackend.TradingFixtures

    @invalid_attrs %{hora_fechamento: nil, data_negocio: nil, codigo_instrumento: nil, preco_negocio: nil, quantidade_negociada: nil}

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Trading.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Trading.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      valid_attrs = %{hora_fechamento: "some hora_fechamento", data_negocio: ~D[2024-02-08], codigo_instrumento: "some codigo_instrumento", preco_negocio: 120.5, quantidade_negociada: 42}

      assert {:ok, %Trade{} = trade} = Trading.create_trade(valid_attrs)
      assert trade.hora_fechamento == "some hora_fechamento"
      assert trade.data_negocio == ~D[2024-02-08]
      assert trade.codigo_instrumento == "some codigo_instrumento"
      assert trade.preco_negocio == 120.5
      assert trade.quantidade_negociada == 42
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trading.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      update_attrs = %{hora_fechamento: "some updated hora_fechamento", data_negocio: ~D[2024-02-09], codigo_instrumento: "some updated codigo_instrumento", preco_negocio: 456.7, quantidade_negociada: 43}

      assert {:ok, %Trade{} = trade} = Trading.update_trade(trade, update_attrs)
      assert trade.hora_fechamento == "some updated hora_fechamento"
      assert trade.data_negocio == ~D[2024-02-09]
      assert trade.codigo_instrumento == "some updated codigo_instrumento"
      assert trade.preco_negocio == 456.7
      assert trade.quantidade_negociada == 43
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Trading.update_trade(trade, @invalid_attrs)
      assert trade == Trading.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Trading.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Trading.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Trading.change_trade(trade)
    end
  end
end
