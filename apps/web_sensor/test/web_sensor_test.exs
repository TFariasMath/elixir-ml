defmodule WebSensorTest do
  use ExUnit.Case
  doctest WebSensor

  test "greets the world" do
    assert WebSensor.hello() == :world
  end
end
