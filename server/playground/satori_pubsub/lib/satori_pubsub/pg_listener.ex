defmodule SatoriPubsub.PgListener do
  use GenServer
  alias Postgrex.Notifications
  @channel "test_channel"

  defstruct [:ref, :pid]

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    {:ok, pid} = Notifications.start_link(SatoriPubsub.Repo.config())
    ref = Notifications.listen!(pid, @channel)
    {:ok, %__MODULE__{pid: pid, ref: ref}}
  end

  def handle_info({:notification, pid, ref, @channel, payload}, %{ref: ref, pid: pid} = state) do
    IO.puts("Message from pubsub: #{inspect(payload)}")
    {:noreply, state}
  end

  def terminate(_reason, %{ref: ref, pid: pid}) do
    Notifications.unlisten!(pid, ref)
    :ok
  end
end
