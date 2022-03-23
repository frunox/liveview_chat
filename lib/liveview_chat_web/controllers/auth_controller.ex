defmodule LiveviewChatWeb.AuthController do
  use LiveviewChatWeb, :controller
  import Phoenix.LiveView, only: [assign_new: 3]

  # pattern match on :default auth and check session has jwt
  def on_mount(:default, _params, %{"jwt" => jwt} = _session, socket) do
    # verify and retrieve jwt stored data
    claims = AuthPlug.Token.verify_jwt!(jwt)

    # assigns the person and the loggedin values
    socket =
      socket
      |> assign_new(:person, fn ->
        AuthPlug.Helpers.strip_struct_metadata(claims)
      end)
      |> assign_new(:loggedin, fn -> true end)

    {:cont, socket}
  end

  # when jwt not defined just returns the current socket
  def on_mount(:default, _params, _session, socket) do
    socket = assign_new(socket, :loggedin, fn -> false end)
    {:cont, socket}
  end

  def login(conn, _params) do
    redirect(conn, external: AuthPlug.get_auth_url(conn, "/"))
  end
end