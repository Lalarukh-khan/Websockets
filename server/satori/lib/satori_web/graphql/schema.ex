defmodule SatoriWeb.GraphQL.Schema do
  use Absinthe.Schema

  alias Satori.PubSub.Subscribe

  object :test do
    field :id, :id
  end

  object :observation do
    field :id, :id
    field :stream_id, :id
    field :target_id, :id

    field :value, :string
  end

  #object :ipfs do
  #  field :id, :id
  #  field :stream_id, :id
  #  field :target_id, :id
  #  field :ipfs, :string
  #end

  query do
    @desc "Test query"
    field :test, :test do
      resolve(fn _, _, _ ->
        {:ok, %{id: Ecto.UUID.generate()}}
      end)
    end

    #@desc "Get a list of ipfs hashes by stream and target"
    #field :ipfs, :ipfs do
    #  arg :stream_id, non_null(:int)
    #  arg :target_id, non_null(:int)
    #  resolve(fn _, %{stream_id: stream_id, target_id: target_id}, _ ->
    #    {:ok, Satori.Pins.list_pins_by_stream_target(stream_id, target_id)}
    #  end)
    #end
  end

  subscription do
    field :test_sub, :test do
      config(fn _, _ ->
        {:ok, topic: "test"}
      end)
    end

    field :observations, :observation do
      arg(:topic, non_null(:string))

      config(fn args, _ ->
        output =
          %Subscribe.Input{
            topic: args.topic
          }
          |> Subscribe.subscribe()

        if output.error == nil do
          {:ok, topic: args.topic}
        else
          {:error, output.error}
        end
      end)
    end
  end
end
