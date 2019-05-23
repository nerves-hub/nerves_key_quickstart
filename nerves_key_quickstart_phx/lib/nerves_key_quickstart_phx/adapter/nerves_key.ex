defmodule NervesKeyQuickstart.Adapter.NervesKey do
  alias NervesKeyQuickstart.Mock

  def transport(opts \\ %{}) do
    case module() do
      NervesKey ->
        {:ok, i2c} = ATECC508A.Transport.I2C.init([])
        i2c

      module ->
        module.transport(opts)
    end
  end

  def device_cert(transport, from \\ :primary) do
    module().device_cert(transport, from)
  end

  def signer_cert(transport, from \\ :primary) do
    module().signer_cert(transport, from)
  end

  def manufacturer_sn(transport) do
    module().manufacturer_sn(transport)
  end

  def has_aux_certificates?(transport) do
    module().has_aux_certificates?(transport)
  end

  def detected?(transport) do
    module().detected?(transport)
  end

  def provisioned?(transport) do
    module().provisioned?(transport)
  end

  def provision(transport, info, signer_cert, signer_key) do
    module().provision(transport, info, signer_cert, signer_key)
  end

  def get_settings(transport) do
    module().get_settings(transport)
  end

  def default_info(transport) do
    module().default_info(transport)
  end

  def create_signing_key_pair(opts) do
    NervesKey.create_signing_key_pair(opts)
  end

  def module do
    Application.get_env(:nerves_key_quickstart_phx, :modules, [])
    |> Keyword.get(NervesKey, Mock.NervesKey)
  end
end
