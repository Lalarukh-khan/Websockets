defmodule Satori.PubSub.TopicInMemory do
  use GenServer

  alias __MODULE__.State

  @behaviour Satori.PubSub.Publish.Topic
  @behaviour Satori.PubSub.Subscribe.Topic

  @name __MODULE__

  @spec start_link(topics :: [binary()]) :: {:ok, pid()}
  def start_link(topics) do
    GenServer.start_link(__MODULE__, State.new(topics), name: @name)
  end

  @impl true
  def maybe_create(topic), do: GenServer.call(__MODULE__, {:maybe_create, topic})

  @impl true
  def validate_exists(topic), do: GenServer.call(__MODULE__, {:validate_exists, topic})

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:maybe_create, topic}, _from, state) do
    {response, state} = State.maybe_create(state, topic)
    {:reply, response, state}
  end

  @impl true
  def handle_call({:validate_exists, topic}, _from, state) do
    {response, state} = State.validate_exists(state, topic)
    {:reply, response, state}
  end
end
