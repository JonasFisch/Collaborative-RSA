defmodule AlgoThink.ChipStorage.CryptoArtifactUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crypto_artifact_users" do

    belongs_to :user, AlgoThink.Accounts.User
    belongs_to :crypto_artifact, AlgoThink.CryptoArtifacts.CryptoArtifact
    belongs_to :study_group, AlgoThink.StudyGroups.StudyGroup

    timestamps()
  end

  @doc false
  def changeset(crypto_artifact_user, attrs) do
    crypto_artifact_user
    |> cast(attrs, [:user_id, :crypto_artifact_id, :study_group_id])
    |> validate_required([:user_id, :crypto_artifact_id, :study_group_id])
  end
end
