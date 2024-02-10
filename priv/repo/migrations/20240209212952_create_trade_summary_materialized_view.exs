defmodule DesafioBackend.Repo.Migrations.CreateTradeSummaryMaterializedView do
  use Ecto.Migration

  def up do
    execute """
    CREATE MATERIALIZED VIEW trade_summary_recent_by_ticker AS
    SELECT
      codigo_instrumento,
      MAX(preco_negocio) AS max_preco,
      SUM(quantidade_negociada) AS total_volume,
      MAX(data_negocio) AS latest_trade_date
    FROM
      trades
    GROUP BY
      codigo_instrumento;
    """

    execute """
    CREATE INDEX ON trade_summary_recent_by_ticker (codigo_instrumento);
    """

    execute """
    CREATE INDEX ON trade_summary_recent_by_ticker (latest_trade_date);
    """
  end

  def down do
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_summary_recent_by_ticker;"
  end
end
