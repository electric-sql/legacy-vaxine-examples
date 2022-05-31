import Config

# Configure your database
config :advanced_counter, AdvancedCounter.Repos.CloudSql,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "advanced_counter_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :advanced_counter, AdvancedCounter.Repos.Cockroach,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "advanced_counter_cockroach_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :advanced_counter, AdvancedCounter.Repos.Antidote,
  hostname: "localhost",
  port: 8087,
  log: true

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :advanced_counter_web, AdvancedCounterWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "opDsWG1UCzJu/z/rFWgNd5luJA5GkMMCLfzL4btuWPp6GOdudO6onvYTzq8eyHbZ",
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :advanced_counter_relay, AdvancedCounterRelay.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4001"))],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "RbiM1yKXsiAKRg+1NfY5UqimhL8/z5awOl7nRLVINMTNN6qO2Bw2b59tTpByPNdH",
  watchers: []

# Watch static and templates for browser reloading.
config :advanced_counter_web, AdvancedCounterWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/advanced_counter_web/(live|views)/.*(ex)$",
      ~r"lib/advanced_counter_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
