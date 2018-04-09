defmodule OmscoreWeb.Router do
  use OmscoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authorize do
    plug OmscoreWeb.AuthorizePlug
    plug OmscoreWeb.MemberFetchPlug
    plug OmscoreWeb.PermissionFetchPlug
  end

  pipeline :fetch_body do
    plug OmscoreWeb.BodyFetchPlug
  end

  pipeline :fetch_circle do
    plug OmscoreWeb.CircleFetchPlug
  end

  scope "/api", OmscoreWeb do
    pipe_through :api

    resources "/bodies", BodyController, except: [:new, :edit] do
      resources "/join_requests", JoinRequestController, except: [:new, :edit]
      # TODO add bound circle router
    end
    resources "/members", MemberController, except: [:new, :edit]
  end

  scope "/api", OmscoreWeb do
    pipe_through [:api, :authorize]
    resources "/permissions", PermissionController, except: [:new, :edit]
    get "/my_permissions", PermissionController, :index_permissions

    get "/circles", CircleController, :index
    post "/circles", CircleController, :create
  end

  scope "/api/circles/:circle_id", OmscoreWeb do
    pipe_through [:api, :authorize, :fetch_circle]

    get "/", CircleController, :show
    put "/", CircleController, :update
    delete "/", CircleController, :delete
    put "/parent", CircleController, :put_parent
    get "/members", CircleController, :show_members
    post "/members", CircleController, :join_circle
    put "/members/:membership_id", CircleController, :update_circle_membership
    delete "/members/:membership_id", CircleController, :delete_circle_membership
    get "/my_permissions", CircleController, :index_permissions
    put "/permissions", CircleController, :put_permissions
  end

  scope "/api/bodies/:body_id", OmscoreWeb, as: :body do
    pipe_through [:api, :authorize, :fetch_body]

    get "/circles", CircleController, :index_bound
    post "/circles", CircleController, :create_bound
  end
end
