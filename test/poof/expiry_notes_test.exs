defmodule Poof.ExpiryNotesTest do
  use Poof.DataCase

  alias Poof.ExpiryNotes

  describe "expiry_notes" do
    alias Poof.ExpiryNotes.ExpiryNote

    import Poof.AccountsFixtures, only: [user_scope_fixture: 0]
    import Poof.ExpiryNotesFixtures

    @invalid_attrs %{body: nil, expiration: nil}

    test "list_expiry_notes/1 returns all scoped expiry_notes" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      other_expiry_note = expiry_note_fixture(other_scope)
      assert ExpiryNotes.list_expiry_notes(scope) == [expiry_note]
      assert ExpiryNotes.list_expiry_notes(other_scope) == [other_expiry_note]
    end

    test "get_expiry_note!/2 returns the expiry_note with given id" do
      scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      other_scope = user_scope_fixture()
      assert ExpiryNotes.get_expiry_note!(scope, expiry_note.id) == expiry_note
      assert_raise Ecto.NoResultsError, fn -> ExpiryNotes.get_expiry_note!(other_scope, expiry_note.id) end
    end

    test "create_expiry_note/2 with valid data creates a expiry_note" do
      valid_attrs = %{body: "some body", expiration: ~U[2025-11-23 21:24:00.000000Z]}
      scope = user_scope_fixture()

      assert {:ok, %ExpiryNote{} = expiry_note} = ExpiryNotes.create_expiry_note(scope, valid_attrs)
      assert expiry_note.body == "some body"
      assert expiry_note.expiration == ~U[2025-11-23 21:24:00.000000Z]
      assert expiry_note.user_id == scope.user.id
    end

    test "create_expiry_note/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = ExpiryNotes.create_expiry_note(scope, @invalid_attrs)
    end

    test "update_expiry_note/3 with valid data updates the expiry_note" do
      scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      update_attrs = %{body: "some updated body", expiration: ~U[2025-11-24 21:24:00.000000Z]}

      assert {:ok, %ExpiryNote{} = expiry_note} = ExpiryNotes.update_expiry_note(scope, expiry_note, update_attrs)
      assert expiry_note.body == "some updated body"
      assert expiry_note.expiration == ~U[2025-11-24 21:24:00.000000Z]
    end

    test "update_expiry_note/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)

      assert_raise MatchError, fn ->
        ExpiryNotes.update_expiry_note(other_scope, expiry_note, %{})
      end
    end

    test "update_expiry_note/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = ExpiryNotes.update_expiry_note(scope, expiry_note, @invalid_attrs)
      assert expiry_note == ExpiryNotes.get_expiry_note!(scope, expiry_note.id)
    end

    test "delete_expiry_note/2 deletes the expiry_note" do
      scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      assert {:ok, %ExpiryNote{}} = ExpiryNotes.delete_expiry_note(scope, expiry_note)
      assert_raise Ecto.NoResultsError, fn -> ExpiryNotes.get_expiry_note!(scope, expiry_note.id) end
    end

    test "delete_expiry_note/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      assert_raise MatchError, fn -> ExpiryNotes.delete_expiry_note(other_scope, expiry_note) end
    end

    test "change_expiry_note/2 returns a expiry_note changeset" do
      scope = user_scope_fixture()
      expiry_note = expiry_note_fixture(scope)
      assert %Ecto.Changeset{} = ExpiryNotes.change_expiry_note(scope, expiry_note)
    end
  end
end
