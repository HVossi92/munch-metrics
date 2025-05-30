defmodule FoodTrackerWeb.Router do
  use FoodTrackerWeb, :router

  import FoodTrackerWeb.UserAuth
  import FoodTrackerWeb.AnonymousAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FoodTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_anonymous_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes for both authenticated and anonymous users
  scope "/", FoodTrackerWeb do
    pipe_through :browser

    # Add a route for setting the anonymous cookie
    get "/set-anonymous-cookie", CookieController, :set_anonymous_cookie

    live_session :public_or_authenticated,
      on_mount: [{FoodTrackerWeb.AnonymousAuth, :ensure_authenticated_or_anonymous}] do
      live "/", Food_TrackLive.Index, :index
      live "/food_tracks", Food_TrackLive.Index, :index
      live "/food_tracks/new", Food_TrackLive.Index, :new
      live "/food_tracks/:id/edit", Food_TrackLive.Index, :edit
      live "/food_tracks/:id", Food_TrackLive.Show, :show
      live "/food_tracks/:id/show/edit", Food_TrackLive.Show, :edit
      live "/monthly", MonthlyLive.Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", FoodTrackerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:food_tracker, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FoodTrackerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", FoodTrackerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [
        {FoodTrackerWeb.UserAuth, :redirect_if_user_is_authenticated},
        {FoodTrackerWeb.AnonymousAuth, :mount_anonymous_user}
      ],
      layout: {FoodTrackerWeb.Layouts, :auth} do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", FoodTrackerWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FoodTrackerWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", FoodTrackerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{FoodTrackerWeb.UserAuth, :mount_current_user}],
      layout: {FoodTrackerWeb.Layouts, :auth} do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/", FoodTrackerWeb do
    pipe_through [:browser]
    get "/privacy", PrivacyController, :index
    get "/tos", TosController, :index
  end
end
