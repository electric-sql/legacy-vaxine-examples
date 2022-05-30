# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :advanced_counter,
  ecto_repos: [
    AdvancedCounter.Repos.CloudSql,
    AdvancedCounter.Repos.Cockroach,
    AdvancedCounter.Repos.Antidote
  ]

config :advanced_counter_relay,
  ecto_repos: [
    AdvancedCounter.Repos.CloudSql,
    AdvancedCounter.Repos.Cockroach,
    AdvancedCounter.Repos.Antidote
  ],
  generators: [context_app: :advanced_counter]

config :advanced_counter, AdvancedCounter.Repos.Cockroach, migration_lock: nil

# Configures the endpoint
config :advanced_counter_web, AdvancedCounterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AdvancedCounterWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AdvancedCounterWeb.PubSub,
  live_view: [signing_salt: "Muhf25ML"]

# Configures the endpoint
config :advanced_counter_relay, AdvancedCounterRelay.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: AdvancedCounterRelay.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: AdvancedCounter.PubSub

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/advanced_counter_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure TailwindCSS
config :tailwind,
  version: "3.0.24",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../apps/advanced_counter_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
