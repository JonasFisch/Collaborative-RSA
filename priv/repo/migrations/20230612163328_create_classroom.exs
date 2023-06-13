defmodule AlgoThink.Repo.Migrations.CreateClassroom do
  use Ecto.Migration

  def change do
    create table(:classroom) do
      add :name, :string, null: false
      add :token, :string, null: false
      add :state, :string
      timestamps()
    end
  end
end
