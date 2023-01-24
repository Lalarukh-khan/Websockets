defmodule Satori.PubSub.Subscribe.Output do
  defstruct [:error]

  @type t :: %__MODULE__{
          error: nil | atom()
        }
end
