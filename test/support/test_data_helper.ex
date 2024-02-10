defmodule DesafioBackend.TestDataHelper do
  @moduledoc """
  Helper functions for setting up test data.
  To partition the trades table and refresh the materialized view.
  """
  alias DesafioBackend.Repo
  alias Ecto.Adapters.SQL

  @type result :: {:ok, SQL.query_result()}

  @spec setup_trade_data(Date.t()) :: result()
  def setup_trade_data(trade_date) do
    partition_name = "trades_#{Date.to_iso8601(trade_date)}"
    start_date = Date.to_iso8601(trade_date)
    end_date = Date.add(trade_date, 1) |> Date.to_iso8601()

    SQL.query(
      Repo,
      """
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relname = '#{partition_name}' AND n.nspname = 'public'
        ) THEN
          EXECUTE format('CREATE TABLE %I PARTITION OF trades FOR VALUES FROM (''%s'') TO (''%s'')', '#{partition_name}', '#{start_date}', '#{end_date}');
        END IF;
      END
      $$;
      """,
      []
    )
  end

  @spec refresh_trade_summary_materialized_view() :: result()
  def refresh_trade_summary_materialized_view do
    SQL.query(
      Repo,
      """
      REFRESH MATERIALIZED VIEW trade_summary_recent_by_ticker;
      """,
      []
    )
  end
end
