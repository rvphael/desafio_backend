defmodule DesafioBackendWeb.Router do
  use DesafioBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DesafioBackendWeb do
    pipe_through :api
  end
end
