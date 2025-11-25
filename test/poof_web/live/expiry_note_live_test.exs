defmodule PoofWeb.ExpiryNoteLiveTest do
  use PoofWeb.ConnCase

  import Phoenix.LiveViewTest
  import Poof.ExpiryNotesFixtures

  @create_attrs %{body: "some body", expiration: "2025-11-23T21:24:00.000000Z"}
  @update_attrs %{body: "some updated body", expiration: "2025-11-24T21:24:00.000000Z"}
  @invalid_attrs %{body: nil, expiration: nil}

  setup :register_and_log_in_user

  defp create_expiry_note(%{scope: scope}) do
    expiry_note = expiry_note_fixture(scope)

    %{expiry_note: expiry_note}
  end

  describe "Index" do
    setup [:create_expiry_note]

    test "lists all expiry_notes", %{conn: conn, expiry_note: expiry_note} do
      {:ok, _index_live, html} = live(conn, ~p"/expiry_notes")

      assert html =~ "Listing Expiry notes"
      assert html =~ expiry_note.body
    end

    test "saves new expiry_note", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/expiry_notes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Expiry note")
               |> render_click()
               |> follow_redirect(conn, ~p"/expiry_notes/new")

      assert render(form_live) =~ "New Expiry note"

      assert form_live
             |> form("#expiry_note-form", expiry_note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expiry_note-form", expiry_note: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expiry_notes")

      html = render(index_live)
      assert html =~ "Expiry note created successfully"
      assert html =~ "some body"
    end

    test "updates expiry_note in listing", %{conn: conn, expiry_note: expiry_note} do
      {:ok, index_live, _html} = live(conn, ~p"/expiry_notes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#expiry_notes-#{expiry_note.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expiry_notes/#{expiry_note}/edit")

      assert render(form_live) =~ "Edit Expiry note"

      assert form_live
             |> form("#expiry_note-form", expiry_note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#expiry_note-form", expiry_note: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expiry_notes")

      html = render(index_live)
      assert html =~ "Expiry note updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes expiry_note in listing", %{conn: conn, expiry_note: expiry_note} do
      {:ok, index_live, _html} = live(conn, ~p"/expiry_notes")

      assert index_live |> element("#expiry_notes-#{expiry_note.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#expiry_notes-#{expiry_note.id}")
    end
  end

  describe "Show" do
    setup [:create_expiry_note]

    test "displays expiry_note", %{conn: conn, expiry_note: expiry_note} do
      {:ok, _show_live, html} = live(conn, ~p"/expiry_notes/#{expiry_note}")

      assert html =~ "Show Expiry note"
      assert html =~ expiry_note.body
    end

    test "updates expiry_note and returns to show", %{conn: conn, expiry_note: expiry_note} do
      {:ok, show_live, _html} = live(conn, ~p"/expiry_notes/#{expiry_note}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/expiry_notes/#{expiry_note}/edit?return_to=show")

      assert render(form_live) =~ "Edit Expiry note"

      assert form_live
             |> form("#expiry_note-form", expiry_note: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#expiry_note-form", expiry_note: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/expiry_notes/#{expiry_note}")

      html = render(show_live)
      assert html =~ "Expiry note updated successfully"
      assert html =~ "some updated body"
    end
  end
end
