defmodule Satori.TargetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Targets` context.
  """

  @doc """
  Generate a target.
  """
  def target_fixture(attrs \\ %{}) do
    {:ok, target} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Satori.Targets.create_target()

    target
  end
end
