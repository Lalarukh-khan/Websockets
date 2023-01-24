defmodule Satori.PubSub.Subscribe.Topic do
  @callback validate_exists(topic :: binary()) :: :ok | {:error, atom()}

  def validate_exists(topic), do: impl().validate_exists(topic)

  defp impl(), do: Application.get_env(:satori, __MODULE__)
end

if function_exported?(Mox, :defmock, 2),
  do: Mox.defmock(Satori.PubSub.Subscribe.TopicMock, for: Satori.PubSub.Subscribe.Topic)
