defmodule AlgoThink.Repo.Migrations.CreateUserTaskLogs do
  use Ecto.Migration

  def change do
    create table(:user_task_logs) do
      add :type, :string
      add :task, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
  end
end
