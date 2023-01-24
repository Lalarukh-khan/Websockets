defmodule Satori.PubSub.Subscribe.Input do
  defstruct [:topic]

  @type t :: %__MODULE__{
          topic: binary()
        }
end
