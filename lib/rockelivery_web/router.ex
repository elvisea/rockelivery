defmodule RockeliveryWeb.Router do
  use RockeliveryWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", RockeliveryWeb do
    pipe_through(:api)

    get("/welcome", WelcomeController, :index)
    get("/users/:id", ComparisonController, :show)
    post("/users", ComparisonController, :create)

    # Rotas para demonstração de tipagem
    get("/typed/users/:id", TypedController, :get_user_typed)
    get("/typed/users-struct/:id", TypedController, :get_user_struct)
    post("/typed/users", TypedController, :create_user_validated)
    get("/typed/users-validation/:id", TypedController, :get_user_with_validation)
    post("/typed/users-centralized", TypedController, :create_user_with_centralized_types)
    get("/typed/compare", TypedController, :compare_typing_approaches)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:rockelivery, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: RockeliveryWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
