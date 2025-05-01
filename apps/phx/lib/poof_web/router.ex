defmodule PoofWeb.Router do
  use PoofWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PoofWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PoofWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/today", TodayLive.Index, :index

    scope "/admin" do
      live "/expiry_notes", ExpiryNoteLive.Index, :index
      live "/expiry_notes/new", ExpiryNoteLive.Form, :new
      live "/expiry_notes/:id", ExpiryNoteLive.Show, :show
      live "/expiry_notes/:id/edit", ExpiryNoteLive.Form, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PoofWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:poof, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PoofWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
