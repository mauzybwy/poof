defmodule Poof.Repo do
  use Ecto.Repo,
    otp_app: :poof,
    adapter: Ecto.Adapters.Postgres
end
