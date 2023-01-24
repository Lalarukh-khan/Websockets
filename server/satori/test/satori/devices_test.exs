defmodule Satori.DevicesTest do
  use Satori.DataCase

  alias Satori.Devices

  describe "devices" do
    alias Satori.Devices.Device

    import Satori.DevicesFixtures

    @invalid_attrs %{bandwidth: nil, cpu: nil, disk: nil, name: nil, ram: nil, wallet_id: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Devices.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{bandwidth: "some bandwidth", cpu: "some cpu", disk: 42, name: "some name", ram: 42, wallet_id: 42}

      assert {:ok, %Device{} = device} = Devices.create_device(valid_attrs)
      assert device.bandwidth == "some bandwidth"
      assert device.cpu == "some cpu"
      assert device.disk == 42
      assert device.name == "some name"
      assert device.ram == 42
      assert device.wallet_id == 42
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{bandwidth: "some updated bandwidth", cpu: "some updated cpu", disk: 43, name: "some updated name", ram: 43, wallet_id: 43}

      assert {:ok, %Device{} = device} = Devices.update_device(device, update_attrs)
      assert device.bandwidth == "some updated bandwidth"
      assert device.cpu == "some updated cpu"
      assert device.disk == 43
      assert device.name == "some updated name"
      assert device.ram == 43
      assert device.wallet_id == 43
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end
  end
end
