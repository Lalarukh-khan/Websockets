defmodule Satori.ObservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Observations` context.
  """

  @doc """
  Generate a observation.
  """
  def observation_fixture(attrs \\ %{}) do
    {:ok, observation} =
      attrs
      |> Enum.into(%{
        stream_id: 42,
        target_id: 42,
        value: "some value",
        wallet_id: 42
      })
      |> Satori.Observations.create_observation()

    observation
  end
end
