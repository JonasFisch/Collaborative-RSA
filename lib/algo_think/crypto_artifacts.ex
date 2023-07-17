defmodule AlgoThink.CryptoArtifacts do
  @moduledoc """
  The CryptoArtifacts context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.Repo

  alias AlgoThink.CryptoArtifacts.CryptoArtifact

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
  def get_crypto_artifact!(id), do: Repo.get!(CryptoArtifact, id)

  @doc """
  Creates a crypto_artifact.

  ## Examples

      iex> create_crypto_artifact(%{field: value})
      {:ok, %CryptoArtifact{}}

      iex> create_crypto_artifact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_crypto_artifact(attrs \\ %{}) do
    %CryptoArtifact{}
    |> CryptoArtifact.changeset(attrs)
    |> Repo.insert()
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

  def create_message(owner_id, message) do
    create_crypto_artifact(%{content: message, type: :message, owner_id: owner_id})
  end

  def encrypt_message(owner_id, message_id, public_key_id) do
    crypto_artifact_message = get_crypto_artifact!(message_id)
    crypto_artifact_public_key = get_crypto_artifact!(public_key_id)
    # validate if key is private key
    if (crypto_artifact_message.type == :message && crypto_artifact_public_key.type == :public_key) do
      {:ok, public_key} = ExPublicKey.loads(crypto_artifact_public_key.content)
      {:ok, cipher_text} = ExPublicKey.encrypt_public(crypto_artifact_message.content, public_key)
      create_crypto_artifact(%{content: cipher_text, type: :message, owner_id: owner_id, encrypted: true})
    else
      raise "given crypo artifact does not contain message or public key!"
    end
  end

  def decrypt_message(encrypted_message_id, private_key_id) do
    IO.inspect(encrypted_message_id)
    crypto_artifact_encrypted_message = get_crypto_artifact!(encrypted_message_id)
    crypto_artifact_private_key = get_crypto_artifact!(private_key_id)

    if (crypto_artifact_encrypted_message.type == :message && crypto_artifact_encrypted_message.encrypted && crypto_artifact_private_key.type == :private_key) do
      {:ok, private_key} = ExPublicKey.loads(crypto_artifact_private_key.content)

      # decrypt and save to db
      {:ok, decrypted_message} = ExPublicKey.decrypt_private(crypto_artifact_encrypted_message.content, private_key)
      create_message(crypto_artifact_encrypted_message.owner_id, decrypted_message)
    else
      raise "given crypo artifacts does not contain encrypted message or private key!"
    end

  end

  def sign_message(owner_id, message_id, private_key_id) do
    crypto_artifact_message = get_crypto_artifact!(message_id)
    crypto_artifact_private_key = get_crypto_artifact!(private_key_id)
    # validate if key is private key
    if (crypto_artifact_message.type == :message && crypto_artifact_private_key.type == :private_key) do
      {:ok, private_key} = ExPublicKey.loads(crypto_artifact_private_key.content)
      {:ok, signature} = ExPublicKey.sign(crypto_artifact_message.content, private_key)
      create_crypto_artifact(%{content: Base.encode64(signature), type: :signature, owner_id: owner_id})
    else
      raise "given crypo artifact does not contain message or private key!"
    end
  end

  def verify_message(message_id, signature_id, public_key_id) do
    crypto_artifact_message = get_crypto_artifact!(message_id)
    crypto_artifact_signature = get_crypto_artifact!(signature_id)
    crypto_artifact_public_key = get_crypto_artifact!(public_key_id)

    if (crypto_artifact_message.type == :message && crypto_artifact_signature.type == :signature && crypto_artifact_public_key.type == :public_key) do
      {:ok, public_key} = ExPublicKey.loads(crypto_artifact_public_key.content)
      {:ok, signature_decoded} = Base.decode64(crypto_artifact_signature.content)
      ExPublicKey.verify(crypto_artifact_message.content, signature_decoded, public_key)
    else
      raise "given crypo artifact does not contain message or private key!"
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
