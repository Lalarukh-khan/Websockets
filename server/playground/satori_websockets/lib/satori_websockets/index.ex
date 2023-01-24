defmodule SatoriWebsockets.Index do
  @pubsub_name :index
  @pubsub_topic "index_updates"

  def take(topic) when is_binary(topic) do
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic, {:take, topic})
  end

  def return(topic) when is_binary(topic) do
    Phoenix.PubSub.broadcast(@pubsub_name, @pubsub_topic, {:return, topic})
  end
end





# defmodule SatoriWebsockets.PgListener do
#   use GenServer

#   def start_link() do
#     GenServer.start_link(__MODULE__, nil, name: __MODULE__)
#   end

#   def get() do
#     GenServer.call(__MODULE__, :get)
#   end

#   def init(_) do
#     Phoenix.PubSub.subscribe(:index, "index_updates")
#     {:ok, %{}}
#   end

#   def handle_call(:get, _, state) do
#     {:reply, state, state}
#   end

#   def handle_info({:take, topic}, state) do
#     IO.puts("Adding (#{topic}) to the list")

#     updated_state = state
#       |> Map.update(topic, &(&1 + topic))

#     {:noreply, updated_state}
#   end

#   def handle_info({:return, topic}, state) do
#     IO.puts("Removing (#{topic}) from the list")

#     updated_state = state
#       |> Map.update(topic, 0, &(&1 - topic))
#       |> Enum.reject(fn({_, v}) -> v <= 0 end)
#       |> Map.new

#     {:noreply, updated_state}
#   end
# end
