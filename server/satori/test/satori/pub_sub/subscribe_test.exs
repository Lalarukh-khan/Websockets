defmodule Satori.PubSub.SubscribeTest do
  use Satori.DataCase
  import Mox

  alias Satori.PubSub.Subscribe
  alias Subscribe.{Input, Output, TopicMock}

  setup :verify_on_exit!

  @mock_topic "test topic"

  @mock_input %Input{topic: @mock_topic}

  describe "subscribe/1" do
    test "calls Topic.validate_exists with topic from input" do
      TopicMock
      |> expect(:validate_exists, fn received_topic ->
        assert received_topic == @mock_topic

        :ok
      end)

      Subscribe.subscribe(@mock_input)
    end

    test "returns %Output{} with nil error" do
      TopicMock
      |> expect(:validate_exists, fn _ ->
        :ok
      end)

      assert %Output{error: nil} == Subscribe.subscribe(@mock_input)
    end
  end

  describe "subscribe/1 when topic does not exist" do
    test "returns %Output{} with nil error" do
      error_mock = :topic_not_found

      TopicMock
      |> expect(:validate_exists, fn _ ->
        {:error, error_mock}
      end)

      assert %Output{error: error_mock} == Subscribe.subscribe(@mock_input)
    end
  end
end
