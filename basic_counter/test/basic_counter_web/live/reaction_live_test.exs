defmodule CountersWeb.ReactionLiveTest do
  use CountersWeb.ConnCase

  import Phoenix.LiveViewTest
  import Counters.ReactionsFixtures

  @create_attrs %{count: 42}
  @update_attrs %{count: 43}
  @invalid_attrs %{count: nil}

  defp create_reaction(_) do
    reaction = reaction_fixture()
    %{reaction: reaction}
  end

  describe "Index" do
    setup [:create_reaction]

    test "lists all reactions", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.reaction_index_path(conn, :index))

      assert html =~ "Listing Reactions"
    end

    test "saves new reaction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.reaction_index_path(conn, :index))

      assert index_live |> element("a", "New Reaction") |> render_click() =~
               "New Reaction"

      assert_patch(index_live, Routes.reaction_index_path(conn, :new))

      assert index_live
             |> form("#reaction-form", reaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reaction-form", reaction: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reaction_index_path(conn, :index))

      assert html =~ "Reaction created successfully"
    end

    test "updates reaction in listing", %{conn: conn, reaction: reaction} do
      {:ok, index_live, _html} = live(conn, Routes.reaction_index_path(conn, :index))

      assert index_live |> element("#reaction-#{reaction.id} a", "Edit") |> render_click() =~
               "Edit Reaction"

      assert_patch(index_live, Routes.reaction_index_path(conn, :edit, reaction))

      assert index_live
             |> form("#reaction-form", reaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#reaction-form", reaction: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reaction_index_path(conn, :index))

      assert html =~ "Reaction updated successfully"
    end

    test "deletes reaction in listing", %{conn: conn, reaction: reaction} do
      {:ok, index_live, _html} = live(conn, Routes.reaction_index_path(conn, :index))

      assert index_live |> element("#reaction-#{reaction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#reaction-#{reaction.id}")
    end
  end

  describe "Show" do
    setup [:create_reaction]

    test "displays reaction", %{conn: conn, reaction: reaction} do
      {:ok, _show_live, html} = live(conn, Routes.reaction_show_path(conn, :show, reaction))

      assert html =~ "Show Reaction"
    end

    test "updates reaction within modal", %{conn: conn, reaction: reaction} do
      {:ok, show_live, _html} = live(conn, Routes.reaction_show_path(conn, :show, reaction))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Reaction"

      assert_patch(show_live, Routes.reaction_show_path(conn, :edit, reaction))

      assert show_live
             |> form("#reaction-form", reaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#reaction-form", reaction: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.reaction_show_path(conn, :show, reaction))

      assert html =~ "Reaction updated successfully"
    end
  end
end
