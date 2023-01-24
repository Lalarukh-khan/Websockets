defmodule Satori.PubSub.Publish.Topic do
  @callback maybe_create(binary()) :: :ok | {:error, atom()}
  def maybe_create(topic), do: impl().maybe_create(topic)

  defp impl(), do: Application.get_env(:satori, __MODULE__)
end

if function_exported?(Mox, :defmock, 2),
  do: Mox.defmock(Satori.PubSub.Publish.TopicMock, for: Satori.PubSub.Publish.Topic)
