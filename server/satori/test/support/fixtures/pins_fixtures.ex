defmodule Satori.PinsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Pins` context.
  """

  @doc """
  Generate a pin.
  """
  def pin_fixture(attrs \\ %{}) do
    {:ok, pin} =
      attrs
      |> Enum.into(%{
        ipns: "some ipns",
        stream_id: 42,
        target_id: 42,
        wallet_id: 42
      })
      |> Satori.Pins.create_pin()

    pin
  end
end
