defmodule OmscoreWeb.AuthorizePlug do
  import Plug.Conn

  def init(default), do: default

  def check_access_token(token) do
    Omscore.Guardian.resource_from_token(token, typ: "access")
  end

  defp check_nil([]), do: {:error, "No X-Auth-Token provided"}
  defp check_nil(data), do: {:ok, data}

  # This plug checks the user token and decodes all user data from it
  def call(conn, _default) do
    with token <- get_req_header(conn, "x-auth-token"),
      {:ok, _} <- check_nil(token),
      token <- Enum.at(token, 0),
      {:ok, user, _claims} <- check_access_token(token)
    do
      conn 
      |> assign(:user, user)
    else
      {:error, msg} -> 
        conn
        |> put_status(:forbidden)
        |> put_resp_content_type("application/json")
        |> send_resp(401, Poison.encode!(%{success: false, error: "Invalid access token", msg: to_string(msg)}))
        |> halt
    end
  end
end