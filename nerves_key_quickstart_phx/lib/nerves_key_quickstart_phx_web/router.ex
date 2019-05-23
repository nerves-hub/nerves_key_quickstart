defmodule NervesKeyQuickstartPhxWeb.Router do
  use NervesKeyQuickstartPhxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NervesKeyQuickstartPhxWeb do
    pipe_through :browser

    live("/", PageLive.Index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", NervesKeyQuickstartPhxWeb do
  #   pipe_through :api
  # end
end
