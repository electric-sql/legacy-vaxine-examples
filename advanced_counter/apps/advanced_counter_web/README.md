# Web interface for advanced counter relays

To start the web interface:

  * Install dependencies with `mix deps.get`
  * Specify a list of available relays in `RELAY_LIST` environment variable
    * `RELAY_LIST` format is a semicolon-separated list of pairs `region=hostname`, e.g `us-central1=http://localhost:4001`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Check the README at the umbrella root for more details.
