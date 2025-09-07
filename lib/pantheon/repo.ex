defmodule Allspark.Repo do
  use Ecto.Repo,
    otp_app: :allspark,
    adapter: Ecto.Adapters.Postgres
end
