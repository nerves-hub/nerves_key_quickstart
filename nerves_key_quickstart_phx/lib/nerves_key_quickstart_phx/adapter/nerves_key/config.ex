defmodule NervesKeyQuickstart.Adapter.NervesKey.Config do
  alias NervesKeyQuickstart.Mock

  defdelegate transport(opts \\ %{}), to: NervesKeyQuickstart.Adapter.NervesKey

  def device_info(transport) do
    module().device_info(transport)
  end

  def device_sn(transport) do
    module().device_sn(transport)
  end

  def module do
    Application.get_env(:nerves_key_quickstart_phx, :modules, [])
    |> Keyword.get(NervesKey.Config, Mock.NervesKey.Config)
  end
end
