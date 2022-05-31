import Config

relay_list =
  System.get_env("RELAY_LIST") ||
    raise """
    environment variable RELAY_LIST is missing.
    Please provide a list of relays to query as a comma-separated list containing pairs in the format of `region=hostname`, e.g. `us-central1=http://localhost:4001`
    """

config :advanced_counter_web,
  relay_list:
    relay_list
    |> String.split(",", trim: true)
    |> Enum.map(&String.split(&1, "=", parts: 2))
    |> Enum.map(&List.to_tuple/1)

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :advanced_counter_web, AdvancedCounterWeb.Endpoint,
  http: [
    # Enable IPv6 and bind on all interfaces.
    # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: secret_key_base

if System.get_env("PHX_SERVER") do
  config :advanced_counter_web, AdvancedCounterWeb.Endpoint, server: true
end
