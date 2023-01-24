defmodule SatoriWeb.TargetLiveTest do
  use SatoriWeb.ConnCase

  import Phoenix.LiveViewTest
  import Satori.TargetsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_target(_) do
    target = target_fixture()
    %{target: target}
  end

  describe "Index" do
    setup [:create_target]

    test "lists all targets", %{conn: conn, target: target} do
      {:ok, _index_live, html} = live(conn, Routes.target_index_path(conn, :index))

      assert html =~ "Listing Targets"
      assert html =~ target.name
    end

    test "saves new target", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.target_index_path(conn, :index))

      assert index_live |> element("a", "New Target") |> render_click() =~
               "New Target"

      assert_patch(index_live, Routes.target_index_path(conn, :new))

      assert index_live
             |> form("#target-form", target: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#target-form", target: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.target_index_path(conn, :index))

      assert html =~ "Target created successfully"
      assert html =~ "some name"
    end

    test "updates target in listing", %{conn: conn, target: target} do
      {:ok, index_live, _html} = live(conn, Routes.target_index_path(conn, :index))

      assert index_live |> element("#target-#{target.id} a", "Edit") |> render_click() =~
               "Edit Target"

      assert_patch(index_live, Routes.target_index_path(conn, :edit, target))

      assert index_live
             |> form("#target-form", target: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#target-form", target: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.target_index_path(conn, :index))

      assert html =~ "Target updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes target in listing", %{conn: conn, target: target} do
      {:ok, index_live, _html} = live(conn, Routes.target_index_path(conn, :index))

      assert index_live |> element("#target-#{target.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#target-#{target.id}")
    end
  end

  describe "Show" do
    setup [:create_target]

    test "displays target", %{conn: conn, target: target} do
      {:ok, _show_live, html} = live(conn, Routes.target_show_path(conn, :show, target))

      assert html =~ "Show Target"
      assert html =~ target.name
    end

    test "updates target within modal", %{conn: conn, target: target} do
      {:ok, show_live, _html} = live(conn, Routes.target_show_path(conn, :show, target))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Target"

      assert_patch(show_live, Routes.target_show_path(conn, :edit, target))

      assert show_live
             |> form("#target-form", target: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#target-form", target: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.target_show_path(conn, :show, target))

      assert html =~ "Target updated successfully"
      assert html =~ "some updated name"
    end
  end
end
