defmodule Poof.ExpiryNotes do
  @moduledoc """
  The ExpiryNotes context.
  """

  import Ecto.Query, warn: false
  alias Poof.Repo

  alias Poof.ExpiryNotes.ExpiryNote
  alias Poof.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any expiry_note changes.

  The broadcasted messages match the pattern:

    * {:created, %ExpiryNote{}}
    * {:updated, %ExpiryNote{}}
    * {:deleted, %ExpiryNote{}}

  """
  def subscribe_expiry_notes(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Poof.PubSub, "user:#{key}:expiry_notes")
  end

  defp broadcast_expiry_note(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Poof.PubSub, "user:#{key}:expiry_notes", message)
  end

  @doc """
  Returns the list of expiry_notes.

  ## Examples

      iex> list_expiry_notes(scope)
      [%ExpiryNote{}, ...]

  """
  def list_expiry_notes(%Scope{} = scope) do
    from(ExpiryNote, where: [user_id: ^scope.user.id], order_by: [asc: :expiration])
    |> Repo.all()
  end

  @doc """
  Gets a single expiry_note.

  Raises `Ecto.NoResultsError` if the Expiry note does not exist.

  ## Examples

      iex> get_expiry_note!(scope, 123)
      %ExpiryNote{}

      iex> get_expiry_note!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_expiry_note!(%Scope{} = scope, id) do
    Repo.get_by!(ExpiryNote, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a expiry_note.

  ## Examples

      iex> create_expiry_note(scope, %{field: value})
      {:ok, %ExpiryNote{}}

      iex> create_expiry_note(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expiry_note(%Scope{} = scope, attrs) do
    with {:ok, expiry_note = %ExpiryNote{}} <-
           %ExpiryNote{}
           |> ExpiryNote.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_expiry_note(scope, {:created, expiry_note})
      {:ok, expiry_note}
    end
  end

  @doc """
  Updates a expiry_note.

  ## Examples

      iex> update_expiry_note(scope, expiry_note, %{field: new_value})
      {:ok, %ExpiryNote{}}

      iex> update_expiry_note(scope, expiry_note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expiry_note(%Scope{} = scope, %ExpiryNote{} = expiry_note, attrs) do
    true = expiry_note.user_id == scope.user.id

    with {:ok, expiry_note = %ExpiryNote{}} <-
           expiry_note
           |> ExpiryNote.changeset(attrs, scope)
           |> IO.inspect()
           |> Repo.update() do
      broadcast_expiry_note(scope, {:updated, expiry_note})
      {:ok, expiry_note}
    end
  end

  @doc """
  Deletes a expiry_note.

  ## Examples

      iex> delete_expiry_note(scope, expiry_note)
      {:ok, %ExpiryNote{}}

      iex> delete_expiry_note(scope, expiry_note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expiry_note(%Scope{} = scope, %ExpiryNote{} = expiry_note) do
    true = expiry_note.user_id == scope.user.id

    with {:ok, expiry_note = %ExpiryNote{}} <-
           Repo.delete(expiry_note) do
      broadcast_expiry_note(scope, {:deleted, expiry_note})
      {:ok, expiry_note}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expiry_note changes.

  ## Examples

      iex> change_expiry_note(scope, expiry_note)
      %Ecto.Changeset{data: %ExpiryNote{}}

  """
  def change_expiry_note(%Scope{} = scope, %ExpiryNote{} = expiry_note, attrs \\ %{}) do
    true = expiry_note.user_id == scope.user.id

    ExpiryNote.changeset(expiry_note, attrs, scope)
  end
end
