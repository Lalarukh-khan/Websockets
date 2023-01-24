defmodule Satori.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Devices` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        bandwidth: "some bandwidth",
        cpu: "some cpu",
        disk: 42,
        name: "some name",
        ram: 42,
        wallet_id: 42
      })
      |> Satori.Devices.create_device()

    device
  end
end
