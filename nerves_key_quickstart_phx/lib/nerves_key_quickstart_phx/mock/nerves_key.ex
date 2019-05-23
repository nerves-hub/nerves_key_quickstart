defmodule NervesKeyQuickstart.Mock.NervesKey do
  @device_cert_pem """
  -----BEGIN CERTIFICATE-----
  MIIBcTCCARegAwIBAgIQSlaC4WQcrXJkvzd/7MHNLzAKBggqhkjOPQQDAjARMQ8w
  DQYDVQQDDAZTaWduZXIwHhcNNzAwMTAxMDAwMDAwWhcNMDEwMTAxMDAwMDAwWjAP
  MQ0wCwYDVQQDDAQxMjM0MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6/+DAO5Y
  LE1w2a2XsaA76ZjpB1gbT7hfFCRVOl20l+DpbTKO9GJ4FypUo7tJ5cMh7UfnZ50n
  +rGRtMHfFEsB+KNTMFEwCQYDVR0TBAIwADAOBgNVHQ8BAf8EBAMCBaAwEwYDVR0l
  BAwwCgYIKwYBBQUHAwIwHwYDVR0jBBgwFoAUNP5pRVEBapHsdQPO8hBj4vUjBi8w
  CgYIKoZIzj0EAwIDSAAwRQIgcQf/aGNpk0s66h3SE04ralPorhvsxb7JFo3sAFU4
  zhMCIQDyn56TzbnJKYi/HuONi3PciJnxQVGuNX3A2vMr290sQQ==
  -----END CERTIFICATE-----
  """

  @signer_cert_pem """
  -----BEGIN CERTIFICATE-----
  MIIBpzCCAU2gAwIBAgIQXj1tCj6UcebW9KzyMQuWozAKBggqhkjOPQQDAjARMQ8w
  DQYDVQQDDAZTaWduZXIwHhcNMTgxMjA0MjAwMDAwWhcNMTkxMjA0MjAwMDAwWjAR
  MQ8wDQYDVQQDDAZTaWduZXIwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAQFp+xv
  6tS2Tf6c+uzkMgAliP8rB+DZt65l31pzRPqpni4LNJWOdvp7NC9dA9R4CrYJlvco
  AljnepawW9Vk0+TBo4GGMIGDMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/
  BAQDAgGGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQU
  NP5pRVEBapHsdQPO8hBj4vUjBi8wHwYDVR0jBBgwFoAUNP5pRVEBapHsdQPO8hBj
  4vUjBi8wCgYIKoZIzj0EAwIDSAAwRQIhAIuXG1T8Bhy02441eBND5ON6Uo/z3vHm
  s5Ya5AZoKO6NAiBNIDR4ebUYzBQSHU9ZnwaiBTVtSbTTXmbhwisDJQ87Jg==
  -----END CERTIFICATE-----
  """

  @settings {:error, :corrupt}

  def transport(opts) do
    opts
  end

  def device_cert(transport, :primary) do
    Map.get(transport, :device_cert, @device_cert_pem)
  end

  def device_cert(transport, :aux) do
    Map.get(transport, :device_cert_aux, @device_cert_pem)
  end

  def signer_cert(transport, :primary) do
    Map.get(transport, :signer_cert, @signer_cert_pem)
  end

  def signer_cert(transport, :aux) do
    Map.get(transport, :signer_cert_aux, @signer_cert_pem)
  end

  def manufacturer_sn(transport) do
    Map.get(transport, :manufacturer_sn, "AERABCD123456789")
  end

  def has_aux_certificates?(transport) do
    Map.get(transport, :has_aux_certificates?, true)
  end

  def detected?(transport) do
    Map.get(transport, :detected?, true)
  end

  def provisioned?(transport) do
    Map.get(transport, :provisioned?, true)
  end

  def provision(transport, _info, _signer_cert, _signer_key) do
    Map.get(transport, :provision, :ok)
  end

  def get_settings(transport) do
    Map.get(transport, :settings, @settings)
  end

  def default_info(transport) do
    Map.get(transport, :default_info, %{
      board_name: "NervesKey",
      manufacturer_sn: "AERABCD123456789"
    })
  end
end
