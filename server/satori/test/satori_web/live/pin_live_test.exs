defmodule SatoriWeb.PinLiveTest do
  use SatoriWeb.ConnCase

  import Phoenix.LiveViewTest
  import Satori.PinsFixtures

  @create_attrs %{ipns: "some ipns", stream_id: 42, target_id: 42, wallet_id: 42}
  @update_attrs %{ipns: "some updated ipns", stream_id: 43, target_id: 43, wallet_id: 43}
  @invalid_attrs %{ipns: nil, stream_id: nil, target_id: nil, wallet_id: nil}

  defp create_pin(_) do
    pin = pin_fixture()
    %{pin: pin}
  end

  describe "Index" do
    setup [:create_pin]

    test "lists all pins", %{conn: conn, pin: pin} do
      {:ok, _index_live, html} = live(conn, Routes.pin_index_path(conn, :index))

      assert html =~ "Listing Pins"
      assert html =~ pin.ipns
    end

    test "saves new pin", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.pin_index_path(conn, :index))

      assert index_live |> element("a", "New Pin") |> render_click() =~
               "New Pin"

      assert_patch(index_live, Routes.pin_index_path(conn, :new))

      assert index_live
             |> form("#pin-form", pin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#pin-form", pin: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pin_index_path(conn, :index))

      assert html =~ "Pin created successfully"
      assert html =~ "some ipns"
    end

    test "updates pin in listing", %{conn: conn, pin: pin} do
      {:ok, index_live, _html} = live(conn, Routes.pin_index_path(conn, :index))

      assert index_live |> element("#pin-#{pin.id} a", "Edit") |> render_click() =~
               "Edit Pin"

      assert_patch(index_live, Routes.pin_index_path(conn, :edit, pin))

      assert index_live
             |> form("#pin-form", pin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#pin-form", pin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pin_index_path(conn, :index))

      assert html =~ "Pin updated successfully"
      assert html =~ "some updated ipns"
    end

    test "deletes pin in listing", %{conn: conn, pin: pin} do
      {:ok, index_live, _html} = live(conn, Routes.pin_index_path(conn, :index))

      assert index_live |> element("#pin-#{pin.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pin-#{pin.id}")
    end
  end

  describe "Show" do
    setup [:create_pin]

    test "displays pin", %{conn: conn, pin: pin} do
      {:ok, _show_live, html} = live(conn, Routes.pin_show_path(conn, :show, pin))

      assert html =~ "Show Pin"
      assert html =~ pin.ipns
    end

    test "updates pin within modal", %{conn: conn, pin: pin} do
      {:ok, show_live, _html} = live(conn, Routes.pin_show_path(conn, :show, pin))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Pin"

      assert_patch(show_live, Routes.pin_show_path(conn, :edit, pin))

      assert show_live
             |> form("#pin-form", pin: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#pin-form", pin: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.pin_show_path(conn, :show, pin))

      assert html =~ "Pin updated successfully"
      assert html =~ "some updated ipns"
    end
  end
end
