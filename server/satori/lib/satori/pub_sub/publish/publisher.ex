defmodule Satori.PubSub.Publish.Publisher do
  @callback publish(topic :: binary(), observation :: map()) :: :ok, {:error, reason :: atom()}
  def publish(topic, observation) do
    impl().publish(topic, observation)
  end

  defp impl do
    Application.get_env(:satori, __MODULE__)
  end
end

if function_exported?(Mox, :defmock, 2),
  do: Mox.defmock(Satori.PubSub.Publish.PublisherMock, for: Satori.PubSub.Publish.Publisher)
