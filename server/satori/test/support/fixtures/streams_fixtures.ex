defmodule Satori.StreamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Satori.Streams` context.
  """

  @doc """
  Generate a stream.
  """
  def stream_fixture(attrs \\ %{}) do
    {:ok, stream} =
      attrs
      |> Enum.into(%{
        cadence: "some cadence",
        name: "some name",
        sanctioned: true,
        source_name: "some source_name",
        prediction_of: nil,
        wallet_id: 42
      })
      |> Satori.Streams.create_stream()

    stream
  end
end
