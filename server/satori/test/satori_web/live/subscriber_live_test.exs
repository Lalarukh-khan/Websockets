defmodule SatoriWeb.SubscriberLiveTest do
  use SatoriWeb.ConnCase

  import Phoenix.LiveViewTest
  import Satori.SubscribersFixtures

  @create_attrs %{device_id: 42, stream_id: 42, target_id: 42}
  @update_attrs %{device_id: 43, stream_id: 43, target_id: 43}
  @invalid_attrs %{device_id: nil, stream_id: nil, target_id: nil}

  defp create_subscriber(_) do
    subscriber = subscriber_fixture()
    %{subscriber: subscriber}
  end

  describe "Index" do
    setup [:create_subscriber]

    test "lists all subscribers", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.subscriber_index_path(conn, :index))

      assert html =~ "Listing Subscribers"
    end

    test "saves new subscriber", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.subscriber_index_path(conn, :index))

      assert index_live |> element("a", "New Subscriber") |> render_click() =~
               "New Subscriber"

      assert_patch(index_live, Routes.subscriber_index_path(conn, :new))

      assert index_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#subscriber-form", subscriber: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.subscriber_index_path(conn, :index))

      assert html =~ "Subscriber created successfully"
    end

    test "updates subscriber in listing", %{conn: conn, subscriber: subscriber} do
      {:ok, index_live, _html} = live(conn, Routes.subscriber_index_path(conn, :index))

      assert index_live |> element("#subscriber-#{subscriber.id} a", "Edit") |> render_click() =~
               "Edit Subscriber"

      assert_patch(index_live, Routes.subscriber_index_path(conn, :edit, subscriber))

      assert index_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#subscriber-form", subscriber: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.subscriber_index_path(conn, :index))

      assert html =~ "Subscriber updated successfully"
    end

    test "deletes subscriber in listing", %{conn: conn, subscriber: subscriber} do
      {:ok, index_live, _html} = live(conn, Routes.subscriber_index_path(conn, :index))

      assert index_live |> element("#subscriber-#{subscriber.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subscriber-#{subscriber.id}")
    end
  end

  describe "Show" do
    setup [:create_subscriber]

    test "displays subscriber", %{conn: conn, subscriber: subscriber} do
      {:ok, _show_live, html} = live(conn, Routes.subscriber_show_path(conn, :show, subscriber))

      assert html =~ "Show Subscriber"
    end

    test "updates subscriber within modal", %{conn: conn, subscriber: subscriber} do
      {:ok, show_live, _html} = live(conn, Routes.subscriber_show_path(conn, :show, subscriber))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Subscriber"

      assert_patch(show_live, Routes.subscriber_show_path(conn, :edit, subscriber))

      assert show_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#subscriber-form", subscriber: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.subscriber_show_path(conn, :show, subscriber))

      assert html =~ "Subscriber updated successfully"
    end
  end
end
