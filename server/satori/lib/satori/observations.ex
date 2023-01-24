defmodule Satori.Observations do
  @moduledoc """
  The Observations context.
  """

  import Ecto.Query, warn: false
  alias Satori.Repo

  alias Satori.Observations.Observation

  @doc """
  Returns the list of observations.

  ## Examples

      iex> list_observations()
      [%Observation{}, ...]

  """
  def list_observations do
    Repo.all(Observation)
  end

  @doc """
  Gets a single observation.

  Raises `Ecto.NoResultsError` if the Observation does not exist.

  ## Examples

      iex> get_observation!(123)
      %Observation{}

      iex> get_observation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_observation!(id), do: Repo.get!(Observation, id)

  @doc """
  Creates a observation.

  ## Examples

      iex> create_observation(%{field: value})
      {:ok, %Observation{}}

      iex> create_observation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_observation(attrs \\ %{}) do
    %Observation{}
    |> Observation.changeset(attrs)
    |> Repo.insert()
    |> _broadcast_observation(:observation_created)
  end

  @doc """
  Updates a observation.

  ## Examples

      iex> update_observation(observation, %{field: new_value})
      {:ok, %Observation{}}

      iex> update_observation(observation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_observation(%Observation{} = observation, attrs) do
    observation
    |> Observation.changeset(attrs)
    |> Repo.update()
    |> _broadcast_observation(:observation_updated)
  end

  @doc """
  Deletes a observation.

  ## Examples

      iex> delete_observation(observation)
      {:ok, %Observation{}}

      iex> delete_observation(observation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_observation(%Observation{} = observation) do
    Repo.delete(observation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking observation changes.

  ## Examples

      iex> change_observation(observation)
      %Ecto.Changeset{data: %Observation{}}

  """
  def change_observation(%Observation{} = observation, attrs \\ %{}) do
    Observation.changeset(observation, attrs)
  end

  ################################################################################
  # Private functions.
  ################################################################################

  defp _broadcast_observation({:ok, observation}, event) do
    Phoenix.PubSub.broadcast(
      Satori.PubSub,
      "observations",
      {event, observation}
    )

    {:ok, observation}
  end

  defp _broadcast_observation({:deleted, observation}, event) do
    Phoenix.PubSub.broadcast(
      CharacterSheets.PubSub,
      "observations",
      {event, observation}
    )

    {:ok, observation}
  end

  defp _broadcast_observation({:error, _changeset} = error, _event), do: error

  #############################################################################
  # Data Loader Functions
  #############################################################################

end
