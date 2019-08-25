# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :nerves_key_quickstart_fw, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"
config :nerves_runtime, :kernel, use_system_registry: false

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

# Configure nerves_init_gadget.
# See https://hexdocs.pm/nerves_init_gadget/readme.html for more information.

# Setting the node_name will enable Erlang Distribution.
# Only enable this for prod if you understand the risks.
node_name = if Mix.env() != :prod, do: "nerves_key_quickstart_fw"

network_config =
  case Mix.target() do
    board when board in [:rpi0, :rpi3a, :bbb] ->
      [ifname: "usb0", address_method: :dhcpd]

    board when board in [:rpi, :rpi2, :rpi3, :rpi4, :x86_64] ->
      [ifname: "eth0", address_method: :dhcp]

    :host ->
      []
  end

init_gadget_config =
  network_config ++
    [
      mdns_domain: "nerves-key.local",
      node_name: node_name,
      node_host: :mdns_domain
    ]

config :nerves_init_gadget, init_gadget_config

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

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
