defmodule Satori.PubSub.Publish.History do
  @spec add_entry(binary(), map()) :: :ok | {:error, atom()}
  def add_entry(_topic, _observation) do
    :ok
  end
end
