defmodule Satori.StreamsTest do
  use Satori.DataCase

  alias Satori.Streams

  describe "streams" do
    alias Satori.Streams.Stream

    import Satori.StreamsFixtures

    @invalid_attrs %{cadence: nil, name: nil, sanctioned: nil, source_name: nil, wallet_id: nil, prediction_of: nil}

    test "list_streams/0 returns all streams" do
      stream = stream_fixture()
      assert Streams.list_streams() == [stream]
    end

    test "get_stream!/1 returns the stream with given id" do
      stream = stream_fixture()
      assert Streams.get_stream!(stream.id) == stream
    end

    test "create_stream/1 with valid data creates a stream" do
      valid_attrs = %{
        cadence: "some cadence",
        name: "some name",
        sanctioned: true,
        source_name: "some source_name",
        prediction_of: nil,
        wallet_id: 42
      }

      assert {:ok, %Stream{} = stream} = Streams.create_stream(valid_attrs)
      assert stream.cadence == "some cadence"
      assert stream.name == "some name"
      assert stream.sanctioned == true
      assert stream.source_name == "some source_name"
      assert stream.prediction_of == nil
      assert stream.wallet_id == 42
    end

    test "create_stream/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Streams.create_stream(@invalid_attrs)
    end

    test "update_stream/2 with valid data updates the stream" do
      stream = stream_fixture()

      update_attrs = %{
        cadence: "some updated cadence",
        name: "some updated name",
        sanctioned: false,
        source_name: "some updated source_name",
        prediction_of: nil,
        wallet_id: 43
      }

      assert {:ok, %Stream{} = stream} = Streams.update_stream(stream, update_attrs)
      assert stream.cadence == "some updated cadence"
      assert stream.name == "some updated name"
      assert stream.sanctioned == false
      assert stream.source_name == "some updated source_name"
      assert stream.prediction_of == nil
      assert stream.wallet_id == 43
    end

    test "update_stream/2 with invalid data returns error changeset" do
      stream = stream_fixture()
      assert {:error, %Ecto.Changeset{}} = Streams.update_stream(stream, @invalid_attrs)
      assert stream == Streams.get_stream!(stream.id)
    end

    test "delete_stream/1 deletes the stream" do
      stream = stream_fixture()
      assert {:ok, %Stream{}} = Streams.delete_stream(stream)
      assert_raise Ecto.NoResultsError, fn -> Streams.get_stream!(stream.id) end
    end

    test "change_stream/1 returns a stream changeset" do
      stream = stream_fixture()
      assert %Ecto.Changeset{} = Streams.change_stream(stream)
    end
  end
end
