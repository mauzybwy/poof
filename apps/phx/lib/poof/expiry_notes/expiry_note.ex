defmodule Poof.ExpiryNotes.ExpiryNote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expiry_notes" do
    field :body, :string
    field :expiration, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(expiry_note, attrs) do
    expiry_note
    |> cast(attrs, [:body, :expiration])
    |> validate_required([:body, :expiration])
  end
end
