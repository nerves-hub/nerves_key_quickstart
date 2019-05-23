defmodule NervesKeyQuickstartFwTest do
  use ExUnit.Case
  doctest NervesKeyQuickstartFw

  test "greets the world" do
    assert NervesKeyQuickstartFw.hello() == :world
  end
end
