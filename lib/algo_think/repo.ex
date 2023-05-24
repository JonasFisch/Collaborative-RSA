defmodule AlgoThink.Repo do
  use Ecto.Repo,
    otp_app: :algo_think,
    adapter: Ecto.Adapters.Postgres
end
