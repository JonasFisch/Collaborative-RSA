defmodule AlgoThink.Repo.Migrations.CreateMessageLatencyLogs do
  use Ecto.Migration

  def change do
    create table(:message_latency_logs) do
      add :latency, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
