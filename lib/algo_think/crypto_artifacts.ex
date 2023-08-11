defmodule AlgoThink.CryptoArtifacts do
  @moduledoc """
  The CryptoArtifacts context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.ChipStorage.CryptoArtifactUser
  alias AlgoThink.StudyGroups
  alias AlgoThink.Repo

  alias AlgoThink.CryptoArtifacts.CryptoArtifact
  alias AlgoThink.Accounts.User

  @doc """
  Returns the list of crypto_artifacts.

  ## Examples

      iex> list_crypto_artifacts()
      [%CryptoArtifact{}, ...]

  """
  def list_crypto_artifacts do
    Repo.all(CryptoArtifact)
  end

  @doc """
  Gets a single crypto_artifact.

  Raises `Ecto.NoResultsError` if the Crypto artifact does not exist.

  ## Examples

      iex> get_crypto_artifact!(123)
      %CryptoArtifact{}

      iex> get_crypto_artifact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_crypto_artifact!(id), do: Repo.get!(CryptoArtifact, id) |> Repo.preload([:owner, :encrypted_for])

  @doc """
  Creates a crypto_artifact.

  ## Examples

      iex> create_crypto_artifact(%{field: value})
      {:ok, %CryptoArtifact{}}

      iex> create_crypto_artifact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_crypto_artifact(attrs \\ %{}) do
    {:ok, crypto_artifact} = %CryptoArtifact{}
    |> CryptoArtifact.changeset(attrs)
    |> Repo.insert()

    {:ok, Repo.preload(crypto_artifact, [:owner, :encrypted_for])
  }
  end

  def create_private_key(owner_id) do
    {:ok, private_key} = ExPublicKey.generate_key(4096)
    {:ok, private_key_pem } = ExPublicKey.pem_encode(private_key)
    create_crypto_artifact(%{content: private_key_pem, type: :private_key, owner_id: owner_id})
  end

  def create_public_key(owner_id, private_key_id) do
    crypto_artifact = get_crypto_artifact!(private_key_id)

    # validate if key is private key
    if (crypto_artifact.type == :private_key) do
      {:ok, private_key} = ExPublicKey.loads(crypto_artifact.content)
      {:ok, public_key} = ExPublicKey.public_key_from_private_key(private_key)
      {:ok, public_key_pem} = ExPublicKey.pem_encode(public_key)
      create_crypto_artifact(%{content: public_key_pem, type: :public_key, owner_id: owner_id})
    else
      raise "given crypo artifact does not contain private key!"
    end
  end

  def generate_public_private_key_pair(owner_id) do
    {:ok, private_key} = AlgoThink.CryptoArtifacts.create_private_key(owner_id)
    {:ok, public_key} = AlgoThink.CryptoArtifacts.create_public_key(owner_id, private_key.id)
    {:ok, %{private_key: private_key, public_key: public_key}}
  end

  def create_message(owner_id, message) do
    create_crypto_artifact(%{content: message, type: :message, owner_id: owner_id})
  end

  def encrypt_message(owner_id, %{message: crypto_artifact_message, public_key: crypto_artifact_public_key}) do
    changeset = AlgoThink.CryptoModuleValidation.changeset_encryption(%{
      message: crypto_artifact_message,
      public_key: crypto_artifact_public_key,
    }, owner_id)
    if (changeset.valid?) do
      {:ok, public_key} = ExPublicKey.loads(crypto_artifact_public_key.content)
      {:ok, cipher_text} = ExPublicKey.encrypt_public(crypto_artifact_message.content, public_key)
      create_crypto_artifact(%{content: cipher_text, type: :message, owner_id: owner_id, encrypted_for_id: crypto_artifact_public_key.owner_id})
    else
      {:error, changeset}
    end
  end

  def decrypt_message(%{message: crypto_artifact_encrypted_message, private_key: crypto_artifact_private_key}) do
    changeset = AlgoThink.CryptoModuleValidation.changeset_decryption(%{
      message: crypto_artifact_encrypted_message,
      private_key: crypto_artifact_private_key,
    })
    if (changeset.valid?) do
      {:ok, private_key} = ExPublicKey.loads(crypto_artifact_private_key.content)

      # decrypt and save to db
      with {:ok, decrypted_message} <- ExPublicKey.decrypt_private(crypto_artifact_encrypted_message.content, private_key) do
        create_message(crypto_artifact_encrypted_message.owner_id, decrypted_message)
      else
        _err ->
          {:error, changeset
            |> Ecto.Changeset.add_error(:private_key, "This key can't decrypt the message.")
          }
      end
    else
      {:error, changeset}
    end
  end

  def create_signature(owner_id, %{message: crypto_artifact_message, private_key: crypto_artifact_private_key}) do
    changeset = AlgoThink.CryptoModuleValidation.changeset_sign(%{
      message: crypto_artifact_message,
      private_key: crypto_artifact_private_key,
    })
    if (changeset.valid?) do
      {:ok, private_key} = ExPublicKey.loads(crypto_artifact_private_key.content)
      {:ok, signature} = ExPublicKey.sign(crypto_artifact_message.content, private_key)
      create_crypto_artifact(%{content: Base.encode64(signature), type: :signature, owner_id: owner_id})
    else
      {:error, changeset}
    end
  end

  def verify_message(%{message: message, signature: signature, public_key: public_key}) do
    changeset = AlgoThink.CryptoModuleValidation.changeset_verify(%{
      message: message,
      signature: signature,
      public_key: public_key,
    })
    if (changeset.valid?) do
      {:ok, public_key} = ExPublicKey.loads(public_key.content)
      {:ok, signature_decoded} = Base.decode64(signature.content)
      {:ok, valid?} = ExPublicKey.verify(message.content, signature_decoded, public_key)
      {:ok, %{valid: valid?, message: message}}
    else
      {:error, changeset}
    end
  end

  def mark_message_as_verified(message_id) do
    %CryptoArtifact{} = message = get_crypto_artifact!(message_id)
    if (message.type == :message) do
      update_crypto_artifact(message, %{signed: true})
    else
      raise "given crypo artifact is not a message."
    end
  end

  @doc """
  Updates a crypto_artifact.

  ## Examples

      iex> update_crypto_artifact(crypto_artifact, %{field: new_value})
      {:ok, %CryptoArtifact{}}

      iex> update_crypto_artifact(crypto_artifact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_crypto_artifact(%CryptoArtifact{} = crypto_artifact, attrs) do
    crypto_artifact
    |> CryptoArtifact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a crypto_artifact.

  ## Examples

      iex> delete_crypto_artifact(crypto_artifact)
      {:ok, %CryptoArtifact{}}

      iex> delete_crypto_artifact(crypto_artifact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_crypto_artifact(%CryptoArtifact{} = crypto_artifact) do
    Repo.delete(crypto_artifact)
  end

  def delete_crypto_artifacts_for_user(%User{} = user, %StudyGroups.StudyGroup{} = study_group) do
    from(
      cau in CryptoArtifactUser,
      join: ca in CryptoArtifact,
      on: ca.id == cau.crypto_artifact_id,
      where: cau.user_id == ^user.id
        and cau.study_group_id == ^study_group.id
        and (
          ca.type not in [:public_key, :private_key]
          or
          ca.owner_id != ^user.id
        )
    ) |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking crypto_artifact changes.

  ## Examples

      iex> change_crypto_artifact(crypto_artifact)
      %Ecto.Changeset{data: %CryptoArtifact{}}

  """
  def change_crypto_artifact(%CryptoArtifact{} = crypto_artifact, attrs \\ %{}) do
    CryptoArtifact.changeset(crypto_artifact, attrs)
  end
end
