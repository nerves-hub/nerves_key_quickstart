defmodule NervesKeyQuickstart.Mock.NervesKey.Config do
  def device_info(transport) do
    Map.get(transport, :device_info, {:ok, %{rev_num: :ecc608_1}})
  end
end
