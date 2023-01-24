defmodule Satori.PinsTest do
  use Satori.DataCase

  alias Satori.Pins

  describe "pins" do
    alias Satori.Pins.Pin

    import Satori.PinsFixtures

    @invalid_attrs %{ipns: nil, stream_id: nil, target_id: nil, wallet_id: nil}

    test "list_pins/0 returns all pins" do
      pin = pin_fixture()
      assert Pins.list_pins() == [pin]
    end

    test "get_pin!/1 returns the pin with given id" do
      pin = pin_fixture()
      assert Pins.get_pin!(pin.id) == pin
    end

    test "create_pin/1 with valid data creates a pin" do
      valid_attrs = %{ipns: "some ipns", stream_id: 42, target_id: 42, wallet_id: 42}

      assert {:ok, %Pin{} = pin} = Pins.create_pin(valid_attrs)
      assert pin.ipns == "some ipns"
      assert pin.stream_id == 42
      assert pin.target_id == 42
      assert pin.wallet_id == 42
    end

    test "create_pin/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pins.create_pin(@invalid_attrs)
    end

    test "update_pin/2 with valid data updates the pin" do
      pin = pin_fixture()
      update_attrs = %{ipns: "some updated ipns", stream_id: 43, target_id: 43, wallet_id: 43}

      assert {:ok, %Pin{} = pin} = Pins.update_pin(pin, update_attrs)
      assert pin.ipns == "some updated ipns"
      assert pin.stream_id == 43
      assert pin.target_id == 43
      assert pin.wallet_id == 43
    end

    test "update_pin/2 with invalid data returns error changeset" do
      pin = pin_fixture()
      assert {:error, %Ecto.Changeset{}} = Pins.update_pin(pin, @invalid_attrs)
      assert pin == Pins.get_pin!(pin.id)
    end

    test "delete_pin/1 deletes the pin" do
      pin = pin_fixture()
      assert {:ok, %Pin{}} = Pins.delete_pin(pin)
      assert_raise Ecto.NoResultsError, fn -> Pins.get_pin!(pin.id) end
    end

    test "change_pin/1 returns a pin changeset" do
      pin = pin_fixture()
      assert %Ecto.Changeset{} = Pins.change_pin(pin)
    end
  end
end
