defmodule Satori.PubSub.Publish.Input do
  defstruct [:topic, :observation]

  @type t :: %__MODULE__{
          topic: binary(),
          observation: map()
        }
end
