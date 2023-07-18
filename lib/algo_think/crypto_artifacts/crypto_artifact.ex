defmodule AlgoThink.CryptoArtifacts.CryptoArtifact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "crypto_artifacts" do
    field :content, :string
    field :encrypted, :boolean, default: false
    field :signed, :boolean, default: false
    field :type, Ecto.Enum, values: [:private_key, :public_key, :signature, :message]
    belongs_to :owner, AlgoThink.Accounts.User
    has_many :crypto_artifact_user, AlgoThink.ChipStorage.CryptoArtifactUser

    timestamps()
  end

  @doc false
  def changeset(crypto_artifact, attrs) do
    crypto_artifact
    |> cast(attrs, [:type, :content, :encrypted, :signed, :owner_id])
    |> validate_required([:type, :content, :owner_id])
  end
end
