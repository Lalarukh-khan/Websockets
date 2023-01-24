defmodule Satori.PubSub.Publish do
  alias __MODULE__.{Input, Output, Topic, History, Publisher}

  @spec publish(Input.t()) :: Output.t()
  def publish(input) do
    with :ok <- Topic.maybe_create(input.topic),
         :ok <- History.add_entry(input.topic, input.observation),
         :ok <- Publisher.publish(input.topic, input.observation) do
      %Output{
        error: nil
      }
    else
      {:error, reason} ->
        %Output{
          error: reason
        }
    end
  end
end
