# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

defmodule Helper do
  def read_secret_from_file(nil, fallback), do: fallback
  def read_secret_from_file(file, fallback) do
    case File.read(file) do
      {:ok, content} -> content
      {:error, _} -> fallback
    end
  end
end

# General application configuration
config :omscore,
  ecto_repos: [Omscore.Repo],
  env: Mix.env,
  url_prefix: System.get_env("BASE_URL") || "www.oms.eu",
  ttl_refresh: 60 * 60 * 24 * 7 * 2,  # 2 weeks
  ttl_access: 60 * 60,                # 1 hour
  ttl_password_reset: 60 * 15,        # 15 Minutes
  ttl_mail_confirmation: 60 * 60 * 2, # 2 hours
  expiry_worker_freq: 5 * 60 * 1000   # 5 Minutes

# Configures the endpoint
config :omscore, OmscoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yHNfTDYdKE4X2gelgWU5vNE7WV0+Mdcgau0JXz+w0xVLrkFOtyssa1fAR5OGY2Nj",
  render_errors: [view: OmscoreWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Omscore.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :omscore, Omscore.Guardian,
  issuer: System.get_env("JWT_ISSUER") || "OMS", 
  secret_key: Helper.read_secret_from_file(System.get_env("JWT_SECRET_KEY_FILE"), "rrSTfyfvFlFj1JCl8QW/ritOLKzIncRPC5ic0l0ENVUoiSIPBCDrdU6Su5vZHngY")

config :omscore, Omscore.Interfaces.Loginservice,
  url: "http://oms-loginservice:4000/api",
  user_delete_provider: :do_nothing

config :omscore, Omscore.Interfaces.Mail,
  from: "alastair@nico-westerbeck.de",
  sendgrid_key: Helper.read_secret_from_file(System.get_env("SENDGRID_KEY_FILE"), "censored")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
