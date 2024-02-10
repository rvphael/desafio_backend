defmodule DesafioBackend.TestDataHelper do
  @moduledoc """
  Helper functions for setting up test data.
  To partition the trades table and refresh the materialized view.
  """
  alias DesafioBackend.Repo

  def setup_trade_data(trade_date) do
    partition_name = "trades_#{Date.to_iso8601(trade_date)}"
    start_date = Date.to_iso8601(trade_date)
    end_date = Date.add(trade_date, 1) |> Date.to_iso8601()

    Ecto.Adapters.SQL.query(
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

  def refresh_trade_summary_materialized_view do
    Ecto.Adapters.SQL.query(
      Repo,
      """
      REFRESH MATERIALIZED VIEW trade_summary_recent_by_ticker;
      """,
      []
    )
  end
end
