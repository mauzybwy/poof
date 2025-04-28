defmodule Poof.ExpiryNotesTest do
  use Poof.DataCase

  alias Poof.ExpiryNotes

  describe "expiry_notes" do
    alias Poof.ExpiryNotes.ExpiryNote

    import Poof.ExpiryNotesFixtures

    @invalid_attrs %{body: nil, expiration: nil}

    test "list_expiry_notes/0 returns all expiry_notes" do
      expiry_note = expiry_note_fixture()
      assert ExpiryNotes.list_expiry_notes() == [expiry_note]
    end

    test "get_expiry_note!/1 returns the expiry_note with given id" do
      expiry_note = expiry_note_fixture()
      assert ExpiryNotes.get_expiry_note!(expiry_note.id) == expiry_note
    end

    test "create_expiry_note/1 with valid data creates a expiry_note" do
      valid_attrs = %{body: "some body", expiration: ~U[2025-04-27 01:07:00.000000Z]}

      assert {:ok, %ExpiryNote{} = expiry_note} = ExpiryNotes.create_expiry_note(valid_attrs)
      assert expiry_note.body == "some body"
      assert expiry_note.expiration == ~U[2025-04-27 01:07:00.000000Z]
    end

    test "create_expiry_note/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ExpiryNotes.create_expiry_note(@invalid_attrs)
    end

    test "update_expiry_note/2 with valid data updates the expiry_note" do
      expiry_note = expiry_note_fixture()
      update_attrs = %{body: "some updated body", expiration: ~U[2025-04-28 01:07:00.000000Z]}

      assert {:ok, %ExpiryNote{} = expiry_note} = ExpiryNotes.update_expiry_note(expiry_note, update_attrs)
      assert expiry_note.body == "some updated body"
      assert expiry_note.expiration == ~U[2025-04-28 01:07:00.000000Z]
    end

    test "update_expiry_note/2 with invalid data returns error changeset" do
      expiry_note = expiry_note_fixture()
      assert {:error, %Ecto.Changeset{}} = ExpiryNotes.update_expiry_note(expiry_note, @invalid_attrs)
      assert expiry_note == ExpiryNotes.get_expiry_note!(expiry_note.id)
    end

    test "delete_expiry_note/1 deletes the expiry_note" do
      expiry_note = expiry_note_fixture()
      assert {:ok, %ExpiryNote{}} = ExpiryNotes.delete_expiry_note(expiry_note)
      assert_raise Ecto.NoResultsError, fn -> ExpiryNotes.get_expiry_note!(expiry_note.id) end
    end

    test "change_expiry_note/1 returns a expiry_note changeset" do
      expiry_note = expiry_note_fixture()
      assert %Ecto.Changeset{} = ExpiryNotes.change_expiry_note(expiry_note)
    end
  end
end
