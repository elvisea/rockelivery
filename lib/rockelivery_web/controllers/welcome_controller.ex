defmodule RockeliveryWeb.WelcomeController do
  use RockeliveryWeb, :controller

  def index(conn, _params) do
    json(conn, %{
      message: "Bem-vindo ao Rockelivery! 🚀",
      status: "success",
      timestamp: DateTime.utc_now()
    })
  end
end
