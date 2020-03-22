# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :nerves_key_quickstart_fw, target: Mix.target()

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

config :phoenix, :template_engines, leex: Phoenix.LiveView.Engine

config :nerves_key_quickstart_phx, NervesKeyQuickstartPhxWeb.Endpoint,
  url: [host: "nerves-key.local"],
  http: [port: 80],
  code_reloader: false,
  server: true,
  secret_key_base:
    System.get_env(
      "SECRET_KEY_BASE",
      "RfoMiFptBfeCcOUmN9ZkUHII7qkEZQxi1r+4sEP1X7NDDUmcYY21Qjms7Xa4PCnu"
    ),
  render_errors: [view: NervesKeyQuickstartPhxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NervesKeyQuickstartPhx.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT", "hCTSF+Yp0MwbMB5lzZRMV/L1JXFL68rI")
  ]

config :nerves_key_quickstart_phx, :modules, [
  {NervesKey, NervesKey},
  {NervesKey.Config, NervesKey.Config}
]

if Mix.target() != :host do
  import_config "target.exs"
end
