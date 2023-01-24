defmodule SatoriWebsockets.PubsubServer do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(init_arg) do
    {:ok, init_arg}
  end

  def publish(server, message) do
    send(server, {:publish, message})
  end

  def subscribe(server, handler) do
    send(server, {:subscribe, self})
    listen(handler)
  end

  def listen(handler) do
    receive do
      message ->
        handler.(message)
        listen(handler)
    end
  end

  def run(subscribers) do
    receive do
      {:publish, message} ->
        Enum.each(subscribers, fn pid -> send(pid, message) end)
        run(subscribers)
      {:subscribe, subscriber} ->
        run([subscriber | subscribers])
    end
  end
  # def run(subscribers, subscriber_callback) do
  #   receive do
  #     {:publish, message} ->
  #       Enum.each(subscribers, fn pid -> send(pid, message) end)
  #       run(subscribers, subscriber_callback)
  #     {:subscribe, subscriber} ->
  #       if subscriber_callback, do: subscriber_callback.(subscriber)
  #       run([subscriber | subscribers], subscriber_callback)
  #   end
  # end


end













# defmodule SatoriWebsockets.PgListener do
#   use GenServer
#   alias Postgrex.Notifications
#   @channel "test_channel"

#   defstruct [:ref, :pid]

#   def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

#   def init(_) do
#     # {:ok, pid} = Notifications.start_link()
#     # ref = Notifications.listen!(pid, @channel)
#     # {:ok, %__MODULE__{pid: pid, ref: ref}}
#     {:ok, %{}}
#   end

#   def handle_info({:notification, pid, ref, @channel, payload}, %{ref: ref, pid: pid} = state) do
#     IO.puts("Message from pubsub: #{inspect(payload)}")
#     {:noreply, state}
#   end

#   def terminate(_reason, %{ref: ref, pid: pid}) do
#     # Notifications.unlisten!(pid, ref)
#     :ok
#   end
# end





# # defmodule SatoriWebsockets.PgListener do
# #   use GenServer

# #   def start_link(:index, opts) do
# #     GenServer.start_link(__MODULE__, nil, name: __MODULE__)
# #   end

# #   def get() do
# #     GenServer.call(__MODULE__, :get)
# #   end

# #   def init(_) do
# #     Phoenix.PubSub.subscribe(:index, "index_updates")
# #     {:ok, %{}}
# #   end

# #   def handle_call(:get, _, state) do
# #     {:reply, state, state}
# #   end

# #   def handle_info({:take, topic}, state) do
# #     IO.puts("Adding (#{topic}) to the list")

# #     updated_state = state
# #       |> Map.update(topic, &(&1 + topic))

# #     {:noreply, updated_state}
# #   end

# #   def handle_info({:return, topic}, state) do
# #     IO.puts("Removing (#{topic}) from the list")

# #     updated_state = state
# #       |> Map.update(topic, 0, &(&1 - topic))
# #       |> Enum.reject(fn({_, v}) -> v <= 0 end)
# #       |> Map.new

# #     {:noreply, updated_state}
# #   end
# # end
