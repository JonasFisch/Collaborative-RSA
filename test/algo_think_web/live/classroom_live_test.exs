defmodule AlgoThinkWeb.ClassroomLiveTest do
  use AlgoThinkWeb.ConnCase

  import Phoenix.LiveViewTest
  import AlgoThink.ClassroomsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_classroom(_) do
    classroom = classroom_fixture()
    %{classroom: classroom}
  end

  describe "Index" do
    setup [:create_classroom]

    test "lists all classroom", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/classroom")

      assert html =~ "Listing Classroom"
    end

    test "saves new classroom", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/classroom")

      assert index_live |> element("a", "New Classroom") |> render_click() =~
               "New Classroom"

      assert_patch(index_live, ~p"/classroom/new")

      assert index_live
             |> form("#classroom-form", classroom: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#classroom-form", classroom: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/classroom")

      html = render(index_live)
      assert html =~ "Classroom created successfully"
    end

    test "updates classroom in listing", %{conn: conn, classroom: classroom} do
      {:ok, index_live, _html} = live(conn, ~p"/classroom")

      assert index_live |> element("#classroom-#{classroom.id} a", "Edit") |> render_click() =~
               "Edit Classroom"

      assert_patch(index_live, ~p"/classroom/#{classroom}/edit")

      assert index_live
             |> form("#classroom-form", classroom: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#classroom-form", classroom: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/classroom")

      html = render(index_live)
      assert html =~ "Classroom updated successfully"
    end

    test "deletes classroom in listing", %{conn: conn, classroom: classroom} do
      {:ok, index_live, _html} = live(conn, ~p"/classroom")

      assert index_live |> element("#classroom-#{classroom.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#classroom-#{classroom.id}")
    end
  end

  describe "Show" do
    setup [:create_classroom]

    test "displays classroom", %{conn: conn, classroom: classroom} do
      {:ok, _show_live, html} = live(conn, ~p"/classroom/#{classroom}")

      assert html =~ "Show Classroom"
    end

    test "updates classroom within modal", %{conn: conn, classroom: classroom} do
      {:ok, show_live, _html} = live(conn, ~p"/classroom/#{classroom}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Classroom"

      assert_patch(show_live, ~p"/classroom/#{classroom}/show/edit")

      assert show_live
             |> form("#classroom-form", classroom: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#classroom-form", classroom: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/classroom/#{classroom}")

      html = render(show_live)
      assert html =~ "Classroom updated successfully"
    end
  end
end
