defmodule AlgoThink.Repo.Migrations.CreateStudyGroups do
  use Ecto.Migration

  def change do
    create table(:study_groups) do
      add :name, :string
      add :classroom_id, references(:classrooms, on_delete: :delete_all)

      timestamps()
    end

    create index(:study_groups, [:classroom_id])
  end
end
