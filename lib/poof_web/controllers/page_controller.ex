defmodule PoofWeb.PageController do
  use PoofWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
