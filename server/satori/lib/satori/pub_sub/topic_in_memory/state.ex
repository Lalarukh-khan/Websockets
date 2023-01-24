defmodule Satori.PubSub.TopicInMemory.State do
  defstruct [:topics]

  @type t :: %__MODULE__{topics: MapSet.t()}

  @spec new() :: t()
  @spec new(topics :: [binary()]) :: t()
  def new(topics \\ []), do: %__MODULE__{topics: MapSet.new(topics)}

  @spec maybe_create(t(), binary()) :: {response :: :ok, state :: t()}
  def maybe_create(state, topic) do
    state =
      state
      |> Map.update!(:topics, &MapSet.put(&1, topic))

    {:ok, state}
  end

  @spec validate_exists(t(), binary()) :: {response :: :ok | {:error, atom()}, state :: t()}
  def validate_exists(state, topic) do
    if MapSet.member?(state.topics, topic) do
      {:ok, state}
    else
      {{:error, :topic_not_found}, state}
    end
  end
end
