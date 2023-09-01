defmodule AlgoThink.Repo.Migrations.CreateTaskMistakeLogs do
  use Ecto.Migration

  def change do
    create table(:task_mistake_logs) do
      add :mistakes, :integer
      add :study_group_id, references(:study_groups, on_delete: :nothing)
      add :task, :string

      timestamps()
    end

    create index(:task_mistake_logs, [:study_group_id])
  end
end
