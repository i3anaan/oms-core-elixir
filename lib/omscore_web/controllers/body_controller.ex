defmodule OmscoreWeb.BodyController do
  use OmscoreWeb, :controller

  alias Omscore.Core
  alias Omscore.Core.Body
  alias Omscore.Members

  action_fallback OmscoreWeb.FallbackController

  def index(conn, _params) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      bodies = Core.list_bodies()
      render(conn, "index.json", bodies: bodies)
    end
  end

  def create(conn, %{"body" => body_params}) do
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "create", "body"),
         {:ok, %Body{} = body} <- Core.create_body(body_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", body_body_path(conn, :show, body.id))
      |> render("show.json", body: body)
    end
  end

  def show(conn, _params) do
    body = conn.assigns.body |> Omscore.Repo.preload([:circles])

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view", "body") do
      render(conn, "show.json", body: body)
    end
  end

  def update(conn, %{"body" => body_params}) do
    body = conn.assigns.body

    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "update", "body"),
         {:ok, %Body{} = body} <- Core.update_body(body, body_params) do
      render(conn, "show.json", body: body)
    end
  end

  def delete(conn, _params) do
    body = conn.assigns.body
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete", "body"),
         {:ok, %Body{}} <- Core.delete_body(body) do
      send_resp(conn, :no_content, "")
    end
  end

  def show_members(conn, _params) do
    body = conn.assigns.body |> Omscore.Repo.preload([body_memberships: [:member]])
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "view_members", "body") do
      render(conn, OmscoreWeb.BodyMembershipView, "index.json", body_memberships: body.body_memberships)
    end
  end

  defp delete_join_request(nil), do: {:ok}
  defp delete_join_request(%Members.JoinRequest{} = join_request) do
    # Rejection == deletion
    # No need to check for results as deletion does not have constraints
    Members.reject_join_request(join_request)
    {:ok}
  end

  def delete_member(conn, %{"membership_id" => membership_id}) do
    bm = Members.get_body_membership!(membership_id)
    jr = Members.get_join_request(bm.body_id, bm.member_id)
    with {:ok, _} <- Core.search_permission_list(conn.assigns.permissions, "delete_member", "body"),
         {:ok, _} <- Members.delete_body_membership(bm),
         {:ok} <- delete_join_request(jr) do
      send_resp(conn, :no_content, "")
    end
  end

  defp check_membership_nil(bm) do
    case bm do
      nil -> {:error, :not_found, "You are not a member of that body"}
      _ -> {:ok}
    end
  end

  def delete_myself(conn, _params) do
    bm = Members.get_body_membership(conn.assigns.body, conn.assigns.member)
    jr = Members.get_join_request(conn.assigns.body, conn.assigns.member)
    with {:ok} <- check_membership_nil(bm),
         {:ok, _} <- Members.delete_body_membership(bm),
         {:ok} <- delete_join_request(jr) do
      send_resp(conn, :no_content, "")       
    end
  end

  def my_permissions(conn, _params) do
    render(conn, OmscoreWeb.PermissionView, "index.json", permissions: conn.assigns.permissions)
  end
end
