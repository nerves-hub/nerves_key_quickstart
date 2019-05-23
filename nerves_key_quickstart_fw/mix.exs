defmodule NervesKeyQuickstartFw.MixProject do
  use Mix.Project

  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :bbb, :x86_64]

  def project do
    [
      app: :nerves_key_quickstart_fw,
      version: "0.1.0",
      elixir: "~> 1.8",
      archives: [nerves_bootstrap: "~> 1.5"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      aliases: [firmware: [&digest_ui/1, :firmware]]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {NervesKeyQuickstartFw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def digest_ui(_) do
    ui_path = Path.expand("../nerves_key_quickstart_phx")

    System.cmd("webpack", ["build", "--production"],
      into: IO.stream(:stdio, :line),
      cd: Path.join(ui_path, "assets")
    )

    System.cmd("mix", ["phx.digest"], into: IO.stream(:stdio, :line), cd: ui_path)
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.4", runtime: false},
      {:shoehorn, "~> 0.4"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:nerves_key_quickstart_phx, path: "../nerves_key_quickstart_phx"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_init_gadget, "~> 0.4", targets: @all_targets},
      {:nerves_key, "~> 0.5.1 or ~> 0.6", targets: @all_targets, override: true},
      {:nerves_time, "~> 0.2", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.6", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.6", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.6", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.6", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.6", runtime: false, targets: :rpi3a},
      {:nerves_system_bbb, "~> 2.0", runtime: false, targets: :bbb},
      {:nerves_system_x86_64, "~> 1.6", runtime: false, targets: :x86_64}
    ]
  end
end
