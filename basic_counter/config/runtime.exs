import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/basic_counter start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :basic_counter, CountersWeb.Endpoint, server: true
end

if config_env() == :prod do
  hostname = System.get_env("DB_HOST")
  socket_dir = System.get_env("DB_SOCKET_DIR")
  socket = System.get_env("DB_SOCKET")

  if !(hostname || socket_dir || socket),
    do:
      raise("""
      Please specify at least one environment variable to connect to the database:
        - use `DB_HOST` to connect to the server hostname
        - use `DB_SOCKET_DIR` to connect via a unix socket derived from the port
        - use `DB_SOCKET` to connect via a unix socket in the given path
      """)

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :basic_counter, Counters.Repo,
    # ssl: true,
    username: System.get_env("DB_USER") || "postgres",
    password: System.get_env("DB_PASS"),
    port: String.to_integer(System.get_env("DB_PORT") || "5432"),
    database:
      System.get_env("DB_NAME") ||
        raise("Please specify a database with DB_NAME environment variable"),
    hostname: System.get_env("DB_HOST"),
    socket_dir: System.get_env("DB_SOCKET_DIR"),
    socket: System.get_env("DB_SOCKET"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :basic_counter, CountersWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
