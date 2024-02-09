defmodule DesafioBackend.Repo do
  use Ecto.Repo,
    otp_app: :desafio_backend,
    adapter: Ecto.Adapters.Postgres
end
