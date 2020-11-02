defmodule NervesKeyQuickstartPhxWeb.PageLive do
  use NervesKeyQuickstartPhxWeb, :live_view

  alias NervesKeyQuickstart.Adapter.NervesKey

  @impl true
  def mount(_params, _session, socket) do
    transport = NervesKey.transport()
    detected? = NervesKey.detected?(transport)
    provisioned? = detected? and NervesKey.provisioned?(transport)

    serial =
      cond do
        detected? and provisioned? ->
          NervesKey.manufacturer_sn(transport)

        detected? ->
          %{manufacturer_sn: serial} = NervesKey.default_info(transport)
          serial

        true ->
          "N/A"
      end

    module_type =
      if detected? do
        {:ok, info} = NervesKey.Config.device_info(transport)

        Map.get(info, :rev_num, "Error getting rev number")
        |> module_type_string()
      end

    device_cert =
      if detected? and provisioned? do
        NervesKey.device_cert(transport)
        |> cert_to_pem()
      end

    signer_cert =
      if detected? and provisioned? do
        NervesKey.signer_cert(transport)
        |> cert_to_pem()
      end

    has_aux_certificates? =
      if detected? and provisioned? do
        NervesKey.has_aux_certificates?(transport)
      else
        false
      end

    device_cert_aux =
      if has_aux_certificates? do
        NervesKey.device_cert(transport, :aux)
        |> cert_to_pem
      end

    signer_cert_aux =
      if has_aux_certificates? do
        NervesKey.signer_cert(transport, :aux)
        |> cert_to_pem
      end

    settings =
      if detected? and provisioned? do
        case NervesKey.get_settings(transport) do
          {:error, :corrupt} -> %{}
          {:ok, value} -> value
        end
        |> IO.inspect()
      end

    {:ok,
     assign(socket,
       transport: transport,
       has_aux_certificates?: has_aux_certificates?,
       detected?: detected?,
       provisioned?: provisioned?,
       module_type: module_type,
       serial: serial,
       device_cert: device_cert,
       device_cert_aux: device_cert_aux,
       signer_cert: signer_cert,
       signer_cert_aux: signer_cert_aux,
       signer_cert_64: "",
       signer_key: "",
       signer_key_64: "",
       years_valid: "3",
       serial_error: nil,
       certificate_error: nil,
       private_key_error: nil,
       years_valid_error: nil,
       settings: settings
     )}
  end

  @impl true
  def render(%{detected?: false} = assigns) do
    NervesKeyQuickstartPhxWeb.PageView.render("no-key.html", assigns)
  end

  def render(%{provisioned?: false} = assigns) do
    NervesKeyQuickstartPhxWeb.PageView.render("provision.html", assigns)
  end

  def render(assigns) do
    NervesKeyQuickstartPhxWeb.PageView.render("configure.html", assigns)
  end

  @impl true
  def handle_event("submit", _payload, %{assigns: assigns} = socket) do
    info = %{manufacturer_sn: assigns.serial, board_name: "NervesKey"}
    signer_cert = X509.Certificate.from_pem!(assigns.signer_cert)
    signer_key = X509.PrivateKey.from_pem!(assigns.signer_key)

    socket =
      case NervesKey.provision(assigns.transport, info, signer_cert, signer_key) do
        :ok -> put_flash(socket, :info, "NervesKey provisioned")
        _ -> put_flash(socket, :error, "An error occurred while provisioning")
      end

    {:noreply, redirect(socket, to: "/")}
  end

  def handle_event("gen-cert", _payload, socket) do
    years_valid = socket.assigns.years_valid

    socket =
      case parse_years_valid(years_valid) do
        years_valid when is_integer(years_valid) ->
          opts = [years_valid: years_valid]
          {cert, key} = NervesKey.create_signing_key_pair(opts)
          signer_cert = X509.Certificate.to_pem(cert)
          signer_key = X509.PrivateKey.to_pem(key)
          send(self(), :validate)

          assign(socket,
            signer_cert: signer_cert,
            signer_cert_64: Base.encode64(signer_cert),
            signer_key: signer_key,
            signer_key_64: Base.encode64(signer_key),
            gen_modal_shown?: false
          )

        nil ->
          assign(socket, years_valid_error: years_valid_validate(years_valid))
      end

    {:noreply, socket}
  end

  def handle_event("gen-modal-open", _payload, socket) do
    {:noreply, assign(socket, gen_modal_shown?: true)}
  end

  def handle_event("gen-modal-close", _payload, socket) do
    {:noreply, assign(socket, gen_modal_shown?: false)}
  end

  def handle_event("validate", payload, socket) do
    send(self(), :validate)
    signer_cert = payload["signer-cert"] || ""
    signer_key = payload["signer-key"] || ""

    {:noreply,
     assign(socket,
       serial: payload["serial"] || "",
       signer_cert: signer_cert,
       signer_cert_64: Base.encode64(signer_cert),
       signer_key: signer_key,
       signer_key_64: Base.encode64(signer_key),
       years_valid: payload["years-valid"] || ""
     )}
  end

  @impl true
  def handle_info(:validate, %{assigns: assigns} = socket) do
    {:noreply,
     assign(socket,
       certificate_error: certificate_validate(assigns.signer_cert),
       private_key_error: private_key_validate(assigns.signer_key),
       serial_error: serial_validate(assigns.serial),
       years_valid_error: years_valid_validate(assigns.years_valid)
     )}
  end

  defp certificate_validate(pem) do
    case X509.Certificate.from_pem(pem) do
      {:ok, _} -> nil
      _ -> "Unable to parse certificate key.\nCertificate must be in PEM format"
    end
  end

  defp private_key_validate(pem) do
    case X509.PrivateKey.from_pem(pem) do
      {:ok, _} -> nil
      _ -> "Unable to parse private key.\nPrivate key must be in PEM format"
    end
  end

  defp serial_validate(serial) when byte_size(serial) > 16 do
    "Manufacturers serial number must be less than 16 bytes"
  end

  defp serial_validate(serial) when byte_size(serial) == 0 do
    "Manufacturers serial number must not be blank"
  end

  defp serial_validate(_serial), do: nil

  defp years_valid_validate(years_valid) when is_binary(years_valid) do
    case Integer.parse(years_valid) do
      :error -> "Unable to parse integer"
      {years_valid, _} -> years_valid_validate(years_valid)
    end
  end

  defp years_valid_validate(years_valid) when years_valid > 31 do
    "Certificate years_valid cannot be > 31 years"
  end

  defp years_valid_validate(years_valid) when years_valid <= 0 do
    "Certificate years_valid must be greater than zero"
  end

  defp years_valid_validate(_years_valid), do: nil

  defp parse_years_valid(years_valid) do
    case Integer.parse(years_valid) do
      :error -> nil
      {years_valid, _} -> years_valid
    end
  end

  def cert_to_pem(cert) when is_binary(cert) do
    cert
  end

  def cert_to_pem(cert) do
    X509.Certificate.to_pem(cert)
  end

  defp module_type_string(:ecc608a_1), do: "ATECC608A Rev 1"
  defp module_type_string(:ecc608a_2), do: "ATECC608A Rev 2"
  defp module_type_string(:ecc508a), do: "ATECC508A"
  defp module_type_string(other), do: to_string(other)
end
