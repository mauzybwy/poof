defmodule Poof.ExpiryNotes.ExpiryNote do
  use Poof.Schema
  import Ecto.Changeset

  schema "expiry_notes" do
    field :body, :string
    field :expiration, :utc_datetime_usec
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expiry_note, attrs, user_scope) do
    expiry_note
    |> cast(attrs, [:body, :expiration])
    |> validate_required([:body, :expiration])
    |> put_change(:user_id, user_scope.user.id)
  end
end
