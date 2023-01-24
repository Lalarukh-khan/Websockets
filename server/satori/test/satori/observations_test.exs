defmodule Satori.ObservationsTest do
  use Satori.DataCase

  alias Satori.Observations

  describe "observations" do
    alias Satori.Observations.Observation

    import Satori.ObservationsFixtures

    @invalid_attrs %{stream_id: nil, target_id: nil, value: nil, wallet_id: nil}

    test "list_observations/0 returns all observations" do
      observation = observation_fixture()
      assert Observations.list_observations() == [observation]
    end

    test "get_observation!/1 returns the observation with given id" do
      observation = observation_fixture()
      assert Observations.get_observation!(observation.id) == observation
    end

    test "create_observation/1 with valid data creates a observation" do
      valid_attrs = %{stream_id: 42, target_id: 42, value: "some value"}

      assert {:ok, %Observation{} = observation} = Observations.create_observation(valid_attrs)
      assert observation.stream_id == 42
      assert observation.target_id == 42
      assert observation.value == "some value"
    end

    test "create_observation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observations.create_observation(@invalid_attrs)
    end

    test "update_observation/2 with valid data updates the observation" do
      observation = observation_fixture()
      update_attrs = %{stream_id: 43, target_id: 43, value: "some updated value"}

      assert {:ok, %Observation{} = observation} =
               Observations.update_observation(observation, update_attrs)

      assert observation.stream_id == 43
      assert observation.target_id == 43
      assert observation.value == "some updated value"
    end

    test "update_observation/2 with invalid data returns error changeset" do
      observation = observation_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Observations.update_observation(observation, @invalid_attrs)

      assert observation == Observations.get_observation!(observation.id)
    end

    test "delete_observation/1 deletes the observation" do
      observation = observation_fixture()
      assert {:ok, %Observation{}} = Observations.delete_observation(observation)
      assert_raise Ecto.NoResultsError, fn -> Observations.get_observation!(observation.id) end
    end

    test "change_observation/1 returns a observation changeset" do
      observation = observation_fixture()
      assert %Ecto.Changeset{} = Observations.change_observation(observation)
    end
  end
end
