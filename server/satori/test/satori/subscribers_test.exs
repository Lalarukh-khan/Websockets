defmodule Satori.SubscribersTest do
  use Satori.DataCase

  alias Satori.Subscribers

  describe "subscribers" do
    alias Satori.Subscribers.Subscriber

    import Satori.SubscribersFixtures

    @invalid_attrs %{device_id: nil, stream_id: nil, target_id: nil}

    test "list_subscribers/0 returns all subscribers" do
      subscriber = subscriber_fixture()
      assert Subscribers.list_subscribers() == [subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = subscriber_fixture()
      assert Subscribers.get_subscriber!(subscriber.id) == subscriber
    end

    test "create_subscriber/1 with valid data creates a subscriber" do
      valid_attrs = %{device_id: 42, stream_id: 42, target_id: 42}

      assert {:ok, %Subscriber{} = subscriber} = Subscribers.create_subscriber(valid_attrs)
      assert subscriber.device_id == 42
      assert subscriber.stream_id == 42
      assert subscriber.target_id == 42
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscribers.create_subscriber(@invalid_attrs)
    end

    test "update_subscriber/2 with valid data updates the subscriber" do
      subscriber = subscriber_fixture()
      update_attrs = %{device_id: 43, stream_id: 43, target_id: 43}

      assert {:ok, %Subscriber{} = subscriber} = Subscribers.update_subscriber(subscriber, update_attrs)
      assert subscriber.device_id == 43
      assert subscriber.stream_id == 43
      assert subscriber.target_id == 43
    end

    test "update_subscriber/2 with invalid data returns error changeset" do
      subscriber = subscriber_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscribers.update_subscriber(subscriber, @invalid_attrs)
      assert subscriber == Subscribers.get_subscriber!(subscriber.id)
    end

    test "delete_subscriber/1 deletes the subscriber" do
      subscriber = subscriber_fixture()
      assert {:ok, %Subscriber{}} = Subscribers.delete_subscriber(subscriber)
      assert_raise Ecto.NoResultsError, fn -> Subscribers.get_subscriber!(subscriber.id) end
    end

    test "change_subscriber/1 returns a subscriber changeset" do
      subscriber = subscriber_fixture()
      assert %Ecto.Changeset{} = Subscribers.change_subscriber(subscriber)
    end
  end
end
