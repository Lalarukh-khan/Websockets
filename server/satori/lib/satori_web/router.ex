defmodule SatoriWeb.Router do
  use SatoriWeb, :router

  import SatoriWeb.UserAuth
  import SatoriWeb.WalletAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {SatoriWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    plug(:fetch_current_wallet)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SatoriWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SatoriWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: SatoriWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", SatoriWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    get("/wallet/register", WalletRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    post("/wallet/register", WalletRegistrationController, :create)
    get("/wallet/log_in", WalletSessionController, :new)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    post("/wallet/log_in", WalletSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope "/", SatoriWeb do
    pipe_through([:browser, :require_authenticated_user])

    live("/devices", DeviceLive.Index, :index)
    live("/devices/new", DeviceLive.Index, :new)
    live("/devices/:id/edit", DeviceLive.Index, :edit)
    live("/devices/:id", DeviceLive.Show, :show)
    live("/devices/:id/show/edit", DeviceLive.Show, :edit)

    live("/observations", ObservationLive.Index, :index)
    live("/observations/new", ObservationLive.Index, :new)
    live("/observations/:id/edit", ObservationLive.Index, :edit)
    live("/observations/:id", ObservationLive.Show, :show)
    live("/observations/:id/show/edit", ObservationLive.Show, :edit)

    live "/pins", PinLive.Index, :index
    live "/pins/new", PinLive.Index, :new
    live "/pins/:id/edit", PinLive.Index, :edit
    live "/pins/:id", PinLive.Show, :show
    live "/pins/:id/show/edit", PinLive.Show, :edit

    live("/streams", StreamLive.Index, :index)
    live("/streams/new", StreamLive.Index, :new)
    live("/streams/:id/edit", StreamLive.Index, :edit)
    live("/streams/:id", StreamLive.Show, :show)
    live("/streams/:id/show/edit", StreamLive.Show, :edit)

    live("/subscribers", SubscriberLive.Index, :index)
    live("/subscribers/new", SubscriberLive.Index, :new)
    live("/subscribers/:id/edit", SubscriberLive.Index, :edit)
    live("/subscribers/:id", SubscriberLive.Show, :show)
    live("/subscribers/:id/show/edit", SubscriberLive.Show, :edit)

    live("/targets", TargetLive.Index, :index)
    live("/targets/new", TargetLive.Index, :new)
    live("/targets/:id/edit", TargetLive.Index, :edit)
    live("/targets/:id", TargetLive.Show, :show)
    live("/targets/:id/show/edit", TargetLive.Show, :edit)

    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings", UserSettingsController, :update)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)

    live("/wallets", WalletLive.Index, :index)
    live("/wallets/new", WalletLive.Index, :new)
    live("/wallets/:id/edit", WalletLive.Index, :edit)
    live("/wallets/:id", WalletLive.Show, :show)
    live("/wallets/:id/show/edit", WalletLive.Show, :edit)


  end

  scope "/", SatoriWeb do
    pipe_through([:browser])

    delete("/wallet/log_out", WalletSessionController, :delete)
    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :edit)
    post("/users/confirm/:token", UserConfirmationController, :update)
  end

  scope "/" do
    pipe_through(:api)

    forward("/api", Absinthe.Plug, schema: SatoriWeb.GraphQL.Schema)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: SatoriWeb.GraphQL.Schema,
      socket: SatoriWeb.UserSocket
    )
  end
end
