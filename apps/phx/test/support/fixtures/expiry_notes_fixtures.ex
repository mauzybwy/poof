defmodule Poof.ExpiryNotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Poof.ExpiryNotes` context.
  """

  @doc """
  Generate a expiry_note.
  """
  def expiry_note_fixture(attrs \\ %{}) do
    {:ok, expiry_note} =
      attrs
      |> Enum.into(%{
        body: "some body",
        expiration: ~U[2025-04-27 01:07:00.000000Z]
      })
      |> Poof.ExpiryNotes.create_expiry_note()

    expiry_note
  end
end
