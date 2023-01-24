defmodule SatoriWeb.PubSub.Publisher do
  @behaviour Satori.PubSub.Publish.Publisher

  @subscription_name :observations

  def publish(topic, observation) do
    Absinthe.Subscription.publish(SatoriWeb.Endpoint, observation, [{@subscription_name, topic}])
  end
end
