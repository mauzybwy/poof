defmodule Poof.ExpiryNotes do
  @moduledoc """
  The ExpiryNotes context.
  """

  import Ecto.Query, warn: false
  alias Poof.Repo

  alias Poof.ExpiryNotes.ExpiryNote

  @doc """
  Returns the list of expiry_notes.

  ## Examples

      iex> list_expiry_notes()
      [%ExpiryNote{}, ...]

  """
  def list_expiry_notes(opts \\ []) do
    from(e in ExpiryNote,
      order_by: ^Keyword.get(opts, :order_by, asc: :expiration)
    )
    |> Repo.all()
  end

  @doc """
  Gets a single expiry_note.

  Raises `Ecto.NoResultsError` if the Expiry note does not exist.

  ## Examples

      iex> get_expiry_note!(123)
      %ExpiryNote{}

      iex> get_expiry_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expiry_note!(id), do: Repo.get!(ExpiryNote, id)

  @doc """
  Creates a expiry_note.

  ## Examples

      iex> create_expiry_note(%{field: value})
      {:ok, %ExpiryNote{}}

      iex> create_expiry_note(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expiry_note(attrs \\ %{}) do
    %ExpiryNote{}
    |> ExpiryNote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a expiry_note.

  ## Examples

      iex> update_expiry_note(expiry_note, %{field: new_value})
      {:ok, %ExpiryNote{}}

      iex> update_expiry_note(expiry_note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expiry_note(%ExpiryNote{} = expiry_note, attrs) do
    expiry_note
    |> ExpiryNote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a expiry_note.

  ## Examples

      iex> delete_expiry_note(expiry_note)
      {:ok, %ExpiryNote{}}

      iex> delete_expiry_note(expiry_note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expiry_note(%ExpiryNote{} = expiry_note) do
    Repo.delete(expiry_note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expiry_note changes.

  ## Examples

      iex> change_expiry_note(expiry_note)
      %Ecto.Changeset{data: %ExpiryNote{}}

  """
  def change_expiry_note(%ExpiryNote{} = expiry_note, attrs \\ %{}) do
    ExpiryNote.changeset(expiry_note, attrs)
  end
end
