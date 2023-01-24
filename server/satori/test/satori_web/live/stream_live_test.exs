defmodule SatoriWeb.StreamLiveTest do
  use SatoriWeb.ConnCase

  import Phoenix.LiveViewTest
  import Satori.StreamsFixtures

  @create_attrs %{cadence: "some cadence", name: "some name", sanctioned: true, source_name: "some source_name", wallet_id: 42, prediction_of: nil}
  @update_attrs %{cadence: "some updated cadence", name: "some updated name", sanctioned: false, source_name: "some updated source_name", wallet_id: 43, prediction_of: nil}
  @invalid_attrs %{cadence: nil, name: nil, sanctioned: false, source_name: nil, wallet_id: nil, prediction_of: nil}

  defp create_stream(_) do
    stream = stream_fixture()
    %{stream: stream}
  end

  describe "Index" do
    setup [:create_stream]

    test "lists all streams", %{conn: conn, stream: stream} do
      {:ok, _index_live, html} = live(conn, Routes.stream_index_path(conn, :index))

      assert html =~ "Listing Streams"
      assert html =~ stream.cadence
    end

    test "saves new stream", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.stream_index_path(conn, :index))

      assert index_live |> element("a", "New Stream") |> render_click() =~
               "New Stream"

      assert_patch(index_live, Routes.stream_index_path(conn, :new))

      assert index_live
             |> form("#stream-form", stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#stream-form", stream: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.stream_index_path(conn, :index))

      assert html =~ "Stream created successfully"
      assert html =~ "some cadence"
    end

    test "updates stream in listing", %{conn: conn, stream: stream} do
      {:ok, index_live, _html} = live(conn, Routes.stream_index_path(conn, :index))

      assert index_live |> element("#stream-#{stream.id} a", "Edit") |> render_click() =~
               "Edit Stream"

      assert_patch(index_live, Routes.stream_index_path(conn, :edit, stream))

      assert index_live
             |> form("#stream-form", stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#stream-form", stream: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.stream_index_path(conn, :index))

      assert html =~ "Stream updated successfully"
      assert html =~ "some updated cadence"
    end

    test "deletes stream in listing", %{conn: conn, stream: stream} do
      {:ok, index_live, _html} = live(conn, Routes.stream_index_path(conn, :index))

      assert index_live |> element("#stream-#{stream.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#stream-#{stream.id}")
    end
  end

  describe "Show" do
    setup [:create_stream]

    test "displays stream", %{conn: conn, stream: stream} do
      {:ok, _show_live, html} = live(conn, Routes.stream_show_path(conn, :show, stream))

      assert html =~ "Show Stream"
      assert html =~ stream.cadence
    end

    test "updates stream within modal", %{conn: conn, stream: stream} do
      {:ok, show_live, _html} = live(conn, Routes.stream_show_path(conn, :show, stream))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Stream"

      assert_patch(show_live, Routes.stream_show_path(conn, :edit, stream))

      assert show_live
             |> form("#stream-form", stream: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#stream-form", stream: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.stream_show_path(conn, :show, stream))

      assert html =~ "Stream updated successfully"
      assert html =~ "some updated cadence"
    end
  end
end
