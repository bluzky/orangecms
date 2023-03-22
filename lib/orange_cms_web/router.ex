defmodule OrangeCmsWeb.Router do
  use OrangeCmsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OrangeCmsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    forward "/gql",
            Absinthe.Plug,
            schema: OrangeCms.Content.Schema

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: OrangeCms.Content.Schema,
            interface: :playground
  end

  scope "/app", OrangeCmsWeb do
    pipe_through [:browser]

    # get "/", PageController, :home

    scope "/" do
      live "/", ProjectLive.Index, :index
      live "/p/new", ProjectLive.Index, :new
    end

    scope "/p/:project_id" do
      live_session :app, on_mount: [OrangeCmsWeb.LoadProject, OrangeCmsWeb.MenuAssign] do
        live "/", ProjectLive.Show, :show
        live "/setup_github", ProjectLive.Show, :setup_github
        live "/fetch_content", ProjectLive.Show, :fetch_content

        scope "/content/:type", ContentEntryLive do
          live "/", Index
          live "/:id", Edit
        end

        scope "/content_types" do
          live "/", ContentTypeLive.Index, :index
          live "/new", ContentTypeLive.Index, :new
          live "/:id", ContentTypeLive.Edit
        end
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OrangeCmsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:orange_cms, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OrangeCmsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
