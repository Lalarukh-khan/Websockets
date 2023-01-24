import Config

config :satori, Satori.PubSub.Publish.Publisher, SatoriWeb.PubSub.Publisher
config :satori, Satori.PubSub.Publish.Topic, Satori.PubSub.TopicInMemory

config :satori, Satori.PubSub.Subscribe.Topic, Satori.PubSub.TopicInMemory
