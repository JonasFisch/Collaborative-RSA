defmodule AlgoThink.Repo.Migrations.CreateCryptoArtifacts do
  use Ecto.Migration

  def change do
    create table(:crypto_artifacts) do
      add :type, :string
      add :content, :text
      add :encrypted_for_id, references(:users, on_delete: :nothing), default: nil, null: true
      add :signed, :boolean, default: false, null: false
      add :owner_id, references(:users, on_delete: :nothing)
      add :valid, :string, null: true

      timestamps()
    end

    create index(:crypto_artifacts, [:owner_id])
  end
end
