defmodule AdvancedCounterWeb.Plugs.ContentSecurityPolicy do
  @behaviour Plug
  import Plug.Conn

  def init(_),
    do:
      Application.get_env(:basic_counter, __MODULE__, [])
      |> build_header()

  def call(conn, header) do
    conn
    |> delete_resp_header("x-frame-options")
    |> put_resp_header("content-security-policy", header)
  end

  defp build_header(opts) do
    opts
    |> Keyword.put_new(:frame_ancestors, ["'self'"])
    |> Enum.map(fn {key, value} ->
      key = key |> Atom.to_string() |> String.replace("_", "-")
      "#{key} #{Enum.join(value, " ")}"
    end)
    |> Enum.join(" ; ")
  end
end
