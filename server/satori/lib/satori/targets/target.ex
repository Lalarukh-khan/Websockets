defmodule Satori.Targets.Target do
  use Ecto.Schema
  import Ecto.Changeset
  alias Satori.Subscribers.Subscriber
  alias Satori.Observations.Observation

  @fields ~w(name)a
  @required ~w(name)a

  schema "targets" do
    field :name, :string

    has_many :subscriber, Subscriber
    has_many :observation, Observation

    timestamps()
  end

  @doc false
  def changeset(target, attrs) do
    target
    |> cast(attrs, @fields)
    |> validate_required(@required)
  end
end
