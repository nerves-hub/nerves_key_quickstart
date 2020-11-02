# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :circuits_quickstart, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1584835471"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :nerves_key_quickstart_phx, NervesKeyQuickstartPhxWeb.Endpoint,
  url: [host: "nerves-key.local"],
  http: [
    port: "80",
    transport_options: [socket_opts: [:inet6]]
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  code_reloader: false,
  server: true,
  secret_key_base: "nYDeisWonkvKTcv2HsWX54SmIfWMc+5gE0mJfo2RkEj7eaBltaLM0pEyweb+YxwE",
  render_errors: [
    view: NervesKeyQuickstartPhxWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: NervesKeyQuickstartPhx.PubSub,
  live_view: [signing_salt: "nWieH1bz"]

config :nerves_key_quickstart_phx, :modules, [
  {NervesKey, NervesKey},
  {NervesKey.Config, NervesKey.Config}
]

if Mix.target() != :host do
  import_config "target.exs"
end
