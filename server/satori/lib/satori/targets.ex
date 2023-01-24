defmodule Satori.Targets do
  @moduledoc """
  The Targets context.
  """

  import Ecto.Query, warn: false
  alias Satori.Repo

  alias Satori.Targets.Target

  @doc """
  Returns the list of targets.

  ## Examples

      iex> list_targets()
      [%Target{}, ...]

  """
  def list_targets do
    Repo.all(Target)
  end

  @doc """
  Gets a single target.

  Raises `Ecto.NoResultsError` if the Target does not exist.

  ## Examples

      iex> get_target!(123)
      %Target{}

      iex> get_target!(456)
      ** (Ecto.NoResultsError)

  """
  def get_target!(id), do: Repo.get!(Target, id)

  @doc """
  Creates a target.

  ## Examples

      iex> create_target(%{field: value})
      {:ok, %Target{}}

      iex> create_target(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_target(attrs \\ %{}) do
    %Target{}
    |> Target.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a target.

  ## Examples

      iex> update_target(target, %{field: new_value})
      {:ok, %Target{}}

      iex> update_target(target, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_target(%Target{} = target, attrs) do
    target
    |> Target.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a target.

  ## Examples

      iex> delete_target(target)
      {:ok, %Target{}}

      iex> delete_target(target)
      {:error, %Ecto.Changeset{}}

  """
  def delete_target(%Target{} = target) do
    Repo.delete(target)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking target changes.

  ## Examples

      iex> change_target(target)
      %Ecto.Changeset{data: %Target{}}

  """
  def change_target(%Target{} = target, attrs \\ %{}) do
    Target.changeset(target, attrs)
  end

  #############################################################################
  # Data Loader Functions
  #############################################################################

end
