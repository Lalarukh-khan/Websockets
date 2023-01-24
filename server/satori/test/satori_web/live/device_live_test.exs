defmodule SatoriWeb.DeviceLiveTest do
  use SatoriWeb.ConnCase

  import Phoenix.LiveViewTest
  import Satori.DevicesFixtures

  @create_attrs %{bandwidth: "some bandwidth", cpu: "some cpu", disk: 42, name: "some name", ram: 42, wallet_id: 42}
  @update_attrs %{bandwidth: "some updated bandwidth", cpu: "some updated cpu", disk: 43, name: "some updated name", ram: 43, wallet_id: 43}
  @invalid_attrs %{bandwidth: nil, cpu: nil, disk: nil, name: nil, ram: nil, wallet_id: nil}

  defp create_device(_) do
    device = device_fixture()
    %{device: device}
  end

  describe "Index" do
    setup [:create_device]

    test "lists all devices", %{conn: conn, device: device} do
      {:ok, _index_live, html} = live(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Listing Devices"
      assert html =~ device.bandwidth
    end

    test "saves new device", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("a", "New Device") |> render_click() =~
               "New Device"

      assert_patch(index_live, Routes.device_index_path(conn, :new))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device created successfully"
      assert html =~ "some bandwidth"
    end

    test "updates device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(index_live, Routes.device_index_path(conn, :edit, device))

      assert index_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_index_path(conn, :index))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated bandwidth"
    end

    test "deletes device in listing", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, Routes.device_index_path(conn, :index))

      assert index_live |> element("#device-#{device.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#device-#{device.id}")
    end
  end

  describe "Show" do
    setup [:create_device]

    test "displays device", %{conn: conn, device: device} do
      {:ok, _show_live, html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Show Device"
      assert html =~ device.bandwidth
    end

    test "updates device within modal", %{conn: conn, device: device} do
      {:ok, show_live, _html} = live(conn, Routes.device_show_path(conn, :show, device))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Device"

      assert_patch(show_live, Routes.device_show_path(conn, :edit, device))

      assert show_live
             |> form("#device-form", device: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#device-form", device: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.device_show_path(conn, :show, device))

      assert html =~ "Device updated successfully"
      assert html =~ "some updated bandwidth"
    end
  end
end
