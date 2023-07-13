defmodule OrangeCmsWeb.Router do
  use OrangeCmsWeb, :router

  import OrangeCmsWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html", "json"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {OrangeCmsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    # plug :load_from_session
  end

  pipeline :api do
    plug(:accepts, ["json"])
    # plug :load_from_session
  end

  pipeline :auth do
    # plug OrangeCmsWeb.LoadMembershipPlug
    # plug OrangeCmsWeb.LoadProjectPlug
  end

  pipeline :not_auth do
    plug(:put_layout, false)
  end

  # scope "/", OrangeCmsWeb do
  #   pipe_through [:browser]
  #   sign_in_route(on_mount: [{OrangeCmsWeb.LiveUserAuth, :live_no_user}])
  #   sign_out_route(AuthController)
  #   auth_routes_for(OrangeCms.Accounts.OUser, to: AuthController)
  #   reset_route([])
  # end

  scope "/", OrangeCmsWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/", PageController, :home)

    scope "/" do
      pipe_through([:auth])

      get("/assets/preview/:project_id/:content_type_id", PreviewController, :preview)
    end

    scope "/api" do
      pipe_through([:api, :auth])
      post("/upload_image/:project_id/:content_type_id", UploadController, :upload_image)
    end

    live_session :authenticated_only,
      on_mount: [{OrangeCmsWeb.UserAuth, :ensure_authenticated}] do
      # on_mount: [
      #   {OrangeCmsWeb.LiveUserAuth, :live_user_required}
      # ] do
      scope "/" do
        live("/p", ProjectLive.Index, :index)
        live("/p/new", ProjectLive.Index, :new)
      end
    end

    scope "/p/:project_id" do
      live_session :project_scope,
        layout: {OrangeCmsWeb.Layouts, :project},
        on_mount: [
          {OrangeCmsWeb.UserAuth, :ensure_authenticated},
          # {OrangeCmsWeb.LiveUserAuth, :live_user_required},
          OrangeCmsWeb.LoadProject
          # OrangeCmsWeb.LoadMembership,
          # OrangeCmsWeb.MenuAssign
        ] do
        live("/", ProjectLive.Show, :show)
        live("/setup/github", ProjectLive.Show, :github_setup)
        live("/setup/github_import_content", ProjectLive.Show, :github_import_content)

        scope "/content/", ContentEntryLive do
          live("/", Index)
          live("/:type", Index)
          live("/:type/:id", Edit)
        end

        scope "/content_types" do
          live("/", ContentTypeLive.Index, :index)
          live("/new", ContentTypeLive.Index, :new)
          live("/:id", ContentTypeLive.Edit)
        end

        scope "/members" do
          live("/", ProjectMemberLive.Index, :index)
          live("/new", ProjectMemberLive.Index, :new)
          live("/:id/edit", ProjectMemberLive.Index, :edit)

          live("/:id", ProjectMemberLive.Show, :show)
          live("/:id/show/edit", ProjectMemberLive.Show, :edit)
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
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: OrangeCmsWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", OrangeCmsWeb do
    pipe_through([:browser, :not_auth, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      layout: false,
      on_mount: [{OrangeCmsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      # live("/register", UserRegistrationLive, :new)
      live("/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/log_in", UserSessionController, :create)
  end

  scope "/", OrangeCmsWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{OrangeCmsWeb.UserAuth, :ensure_authenticated}] do
      live("/users/settings", UserSettingsLive, :edit)
      live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)

      scope "/users" do
        live("/", UserLive.Index, :index)
        live("/new", UserLive.Index, :new)
        live("/:id/edit", UserLive.Index, :edit)

        live("/:id", UserLive.Show, :show)
        live("/:id/show/edit", UserLive.Show, :edit)
      end
    end
  end

  scope "/", OrangeCmsWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{OrangeCmsWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
