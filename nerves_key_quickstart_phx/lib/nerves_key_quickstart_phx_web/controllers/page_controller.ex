defmodule NervesKeyQuickstartPhxWeb.PageController do
  use NervesKeyQuickstartPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
