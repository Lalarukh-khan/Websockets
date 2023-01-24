defmodule Satori.PubSub.Subscribe do
  alias __MODULE__.{Input, Output, Topic}

  @spec subscribe(Input.t()) :: Output.t()
  def subscribe(input) do
    with :ok <- Topic.validate_exists(input.topic) do
      %Output{
        error: nil
      }
    else
      {:error, reason} -> %Output{error: reason}
    end
  end
end
