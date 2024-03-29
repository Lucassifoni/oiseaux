# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :scope, ScopeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ScopeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Scope.PubSub,
  check_origin: ["http://localhost:5173", "http://localhost:4000", "http://localhost:5174"],
  live_view: [signing_salt: "S1hliA6z"]

config :scope,
  selected_io: Scope.PhysicalRemote,
  selected_device: Scope.VirtualTelescope,
  platform: if (System.get_env("SCOPE_PLATFORM", "MACOS") == "MACOS"), do: :macos, else: :nezha

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :scope, Scope.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
