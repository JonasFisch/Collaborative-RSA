defmodule AlgoThink.Repo.Migrations.CreateCryptoartifactUsers do
  use Ecto.Migration

  def change do
    create table(:crypto_artifact_users) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :crypto_artifact_id, references(:crypto_artifacts, on_delete: :delete_all)
      add :study_group_id, references(:study_groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:crypto_artifact_users, [:user_id])
    create index(:crypto_artifact_users, [:crypto_artifact_id])
    create index(:crypto_artifact_users, [:study_group_id])
  end
end
