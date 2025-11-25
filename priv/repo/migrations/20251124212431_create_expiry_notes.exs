defmodule Poof.Repo.Migrations.CreateExpiryNotes do
  use Ecto.Migration

  def change do
    create table(:expiry_notes) do
      add :body, :text
      add :expiration, :utc_datetime_usec
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:expiry_notes, [:user_id])
  end
end
