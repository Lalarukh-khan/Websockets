defmodule Satori.PubSub.PublishTest do
  use Satori.DataCase
  import Mox

  alias Satori.PubSub.Publish
  alias Publish.{Input, Output, PublisherMock, TopicMock}

  setup :verify_on_exit!

  @mock_topic "test topic"
  @mock_observation %{"some" => "test", "data" => "here"}

  @mock_input %Input{topic: @mock_topic, observation: @mock_observation}

  describe "publish/1" do
    @publisher_return :ok

    setup :stub_maybe_create

    test "calls Publisher.publish/2 with topic and observation from %Input{}" do
      PublisherMock
      |> expect(:publish, fn received_topic, received_observation ->
        assert @mock_topic == received_topic
        assert @mock_observation == received_observation

        @publisher_return
      end)

      Publish.publish(@mock_input)
    end

    test "returns %Output{} with nil error" do
      PublisherMock
      |> expect(:publish, fn _, _ ->
        @publisher_return
      end)

      assert %Output{error: nil} == Publish.publish(@mock_input)
    end
  end

  describe "publish/1 when Publisher returns error" do
    @mock_error :some_important_reason
    @publisher_return {:error, @mock_error}

    setup :stub_maybe_create

    test "returns %Output{} with the same error" do
      PublisherMock
      |> expect(:publish, fn _, _ ->
        @publisher_return
      end)

      assert %Output{error: @mock_error} == Publish.publish(@mock_input)
    end
  end

  defp stub_maybe_create(params) do
    TopicMock
    |> stub(:maybe_create, fn _ -> :ok end)

    params
  end
end
