defmodule Satori.SubscribersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Subscribers` context.
  """

  @doc """
  Generate a subscriber.
  """
  def subscriber_fixture(attrs \\ %{}) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(%{
        device_id: 42,
        stream_id: 42,
        target_id: 42
      })
      |> Satori.Subscribers.create_subscriber()

    subscriber
  end
end
