defmodule Poof.Repo.Migrations.CreateExpiryNotes do
  use Ecto.Migration

  def change do
    create table(:expiry_notes) do
      add :body, :text
      add :expiration, :utc_datetime_usec

      timestamps(type: :utc_datetime)
    end
  end
end
