defmodule Poof.ExpiryNotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poof.ExpiryNotes` context.
  """

  @doc """
  Generate a expiry_note.
  """
  def expiry_note_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        expiration: ~U[2025-11-23 21:24:00.000000Z]
      })

    {:ok, expiry_note} = Poof.ExpiryNotes.create_expiry_note(scope, attrs)
    expiry_note
  end
end
