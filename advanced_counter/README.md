# Advanced counter demo for Vaxine DB

Advanced counter demo is intended to demonstrate how different databases deal with geo-distributed write workload.

This project consists of two applications: `apps/advanced_counter_relay` is an API backend application that connects to the databases and performs the workload, and `apps/advanced_counter_web` is a web application that interacts with relays to collect and display the relevant data. To learn more, go to [our hosted version](https://vaxine.io/demos/advanced_counter) and try it out for yourself!

## Running locally

### Web application

Web application does not depend on the databases to be ran, instead requiring a list of running relays with their hosts and datacenter regions.

1. Install dependencies:
   `mix deps.get`
2. Set the environment variable describing available relays:
   `export RELAY_LIST="asia-northeast1=https://advanced-counter-demo--asia-northeast1-dgdu2db37q-an.a.run.app,europe-west2=https://advanced-counter-demo--europe-west2-dgdu2db37q-nw.a.run.app,us-central1=https://advanced-counter-demo--us-central1-dgdu2db37q-uc.a.run.app"`
   The `RELAY_LIST` variable should be formatted as a comma-separated list of pairs `region=hostname`. If you're running relays locally, just specify it as any region: `us-central1=http://localhost:4001`
3. Run the web application:
   `cd apps/advanced_counter_web && mix phx.server`
   It should be available at http://localhost:4000.

### Relays

Relays are meant to be spread out in different datacenters, since they emulate writes from across the world. You can, however, run a relay locally if you have Postgres running on port 5432 and Antidote on port 8081 locally.

1. Install dependencies:
   `mix deps.get`
2. Run the relay:
   `cd apps/advanced_counter_relay && mix phx.server`
   It should be available at http://localhost:4001.

### Current list of relays

- `asia-northeast1`: `https://advanced-counter-demo--asia-northeast1-dgdu2db37q-an.a.run.app`
- `europe-west2`: `https://advanced-counter-demo--europe-west2-dgdu2db37q-nw.a.run.app`
- `us-central1` : `https://advanced-counter-demo--us-central1-dgdu2db37q-uc.a.run.app`
