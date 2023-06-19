defmodule AlgoThink.Repo.Migrations.CreateClassroomUsers do
  use Ecto.Migration

  def change do
    create table(:classroom_users) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :classroom_id, references(:classroom, on_delete: :delete_all)

      timestamps()
    end
    create unique_index(:classroom_users, [:user_id, :classroom_id], name: :classroom_user_unique)
  end
end
