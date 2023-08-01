defmodule AlgoThinkWeb.Router do
  alias StudyGroupLive
  alias ClassroomLive
  use AlgoThinkWeb, :router

  import AlgoThinkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AlgoThinkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AlgoThinkWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", AlgoThinkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:algo_think, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AlgoThinkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AlgoThinkWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AlgoThinkWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end


    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AlgoThinkWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :home

    live_session :require_authenticated_user,
      root_layout: {AlgoThinkWeb.Layouts, :root},
      on_mount: [{AlgoThinkWeb.UserAuth, :ensure_authenticated}] do
      live "/classroom", ClassroomLive.Index, :index
      live "/classroom/new", ClassroomLive.Index, :new
      live "/classroom/join", ClassroomLive.Index, :join
      live "/classroom/:id/edit", ClassroomLive.Index, :edit

      live "/classroom/:id", ClassroomLive.Show, :show
      live "/classroom/:id/show/edit", ClassroomLive.Show, :edit
    end

    live_session :game, root_layout: {AlgoThinkWeb.Layouts, :root_game},
      on_mount: [{AlgoThinkWeb.UserAuth, :ensure_authenticated}] do

      live "/classroom/:id/studygroup/:study_group_id", StudyGroupLive.Index, :index, container: {:div, class: "h-game"}
    end
  end


  # user session and token handling
  scope "/", AlgoThinkWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AlgoThinkWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
