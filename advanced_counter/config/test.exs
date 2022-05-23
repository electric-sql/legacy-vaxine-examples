import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :advanced_counter_relay, AdvancedCounterRelay.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4003],
  secret_key_base: "76Vm6+9I0hjPZJE2ywCNS0IHCCnUTEVv54OOW8E9R68XbIo6RLzGrdr10tSTVOcG",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :advanced_counter_web, AdvancedCounterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mpr0RloNPVi3NrXkdAGAe3z3yBpemvv8uxlD79W6TsE6ABJa5i1j+j6SHPI3/xNk",
  server: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :advanced_counter, AdvancedCounter.Repos.CloudSql,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "advanced_counter_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :advanced_counter, AdvancedCounter.Repos.Cockroach,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "advanced_counter_cockroach_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10


# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
