defmodule AlgoThink.Repo.Migrations.CreateClassroomUsers do
  use Ecto.Migration

  def change do
    create table(:classroom_users) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :classroom_id, references(:classrooms, on_delete: :delete_all)
      add :study_group_id, references(:study_groups, on_delete: :nilify_all), null: true
      add :has_key_pair, :boolean

      timestamps()
    end
    create unique_index(:classroom_users, [:user_id, :classroom_id], name: :classroom_user_unique)
  end
end
