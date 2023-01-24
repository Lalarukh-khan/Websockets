defmodule Satori.Pins do
  @moduledoc """
  The Pins context.
  """

  import Ecto.Query, warn: false
  alias Satori.Repo

  alias Satori.Pins.Pin

  @doc """
  Returns the list of pins.

  ## Examples

      iex> list_pins()
      [%Pin{}, ...]

  """
  def list_pins do
    Repo.all(Pin)
  end

  @doc """
  Gets a single pin.

  Raises `Ecto.NoResultsError` if the Pin does not exist.

  ## Examples

      iex> get_pin!(123)
      %Pin{}

      iex> get_pin!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pin!(id), do: Repo.get!(Pin, id)

  @doc """
  Creates a pin.

  ## Examples

      iex> create_pin(%{field: value})
      {:ok, %Pin{}}

      iex> create_pin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pin(attrs \\ %{}) do
    %Pin{}
    |> Pin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pin.

  ## Examples

      iex> update_pin(pin, %{field: new_value})
      {:ok, %Pin{}}

      iex> update_pin(pin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pin(%Pin{} = pin, attrs) do
    pin
    |> Pin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pin.

  ## Examples

      iex> delete_pin(pin)
      {:ok, %Pin{}}

      iex> delete_pin(pin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pin(%Pin{} = pin) do
    Repo.delete(pin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pin changes.

  ## Examples

      iex> change_pin(pin)
      %Ecto.Changeset{data: %Pin{}}

  """
  def change_pin(%Pin{} = pin, attrs \\ %{}) do
    Pin.changeset(pin, attrs)
  end

  #############################################################################
  # Resolver Functions
  #############################################################################

  @doc """
  Gets a list of pins by stream and target id.

  Raises `Ecto.NoResultsError` if the Pin does not exist.

  ## Examples

      iex> get_pin!(123)
      %Pin{}

      iex> get_pin!(456)
      ** (Ecto.NoResultsError)

  """
  def list_pins_by_stream_target(stream_id, target_id) do
    Repo.get_by(Pin, stream_id: stream_id, target_id: target_id)
  end

  #############################################################################
  # Data Loader Functions
  #############################################################################

end
