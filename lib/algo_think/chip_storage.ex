defmodule AlgoThink.ChipStorage do
  @moduledoc """
  The ChipStorage context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.CryptoArtifacts.CryptoArtifact
  alias AlgoThink.Repo

  alias AlgoThink.ChipStorage.CryptoArtifactUser

  @doc """
  Returns the list of cryptoartifact_users.

  ## Examples

      iex> list_cryptoartifact_users()
      [%CryptoArtifactUser{}, ...]

  """
  def list_cryptoartifact_users do
    Repo.all(CryptoArtifactUser)
  end

  # Lists all the crypto_artifacts the user has in storage
  def list_cryptoartifact_for_user(user_id, study_group_id) do
    Repo.all(from(
      c in CryptoArtifact,
      join: cau in assoc(c, :crypto_artifact_user),
      where: cau.user_id == ^user_id and cau.study_group_id == ^study_group_id,
      order_by: cau.inserted_at,
      preload: [:owner, :encrypted_for]
    ))
  end

  @doc """
  Gets a single crypto_artifact_user.

  Raises `Ecto.NoResultsError` if the Crypto artifact user does not exist.

  ## Examples

      iex> get_crypto_artifact_user!(123)
      %CryptoArtifactUser{}

      iex> get_crypto_artifact_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_crypto_artifact_user!(id), do: Repo.get!(CryptoArtifactUser, id)

  @doc """
  Creates a crypto_artifact_user.

  ## Examples

      iex> create_crypto_artifact_user(%{field: value})
      {:ok, %CryptoArtifactUser{}}

      iex> create_crypto_artifact_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_crypto_artifact_user(attrs \\ %{}) do
    %CryptoArtifactUser{}
    |> CryptoArtifactUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a crypto_artifact_user.

  ## Examples

      iex> update_crypto_artifact_user(crypto_artifact_user, %{field: new_value})
      {:ok, %CryptoArtifactUser{}}

      iex> update_crypto_artifact_user(crypto_artifact_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_crypto_artifact_user(%CryptoArtifactUser{} = crypto_artifact_user, attrs) do
    crypto_artifact_user
    |> CryptoArtifactUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a crypto_artifact_user.

  ## Examples

      iex> delete_crypto_artifact_user(crypto_artifact_user)
      {:ok, %CryptoArtifactUser{}}

      iex> delete_crypto_artifact_user(crypto_artifact_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_crypto_artifact_user(%CryptoArtifactUser{} = crypto_artifact_user) do
    Repo.delete(crypto_artifact_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking crypto_artifact_user changes.

  ## Examples

      iex> change_crypto_artifact_user(crypto_artifact_user)
      %Ecto.Changeset{data: %CryptoArtifactUser{}}

  """
  def change_crypto_artifact_user(%CryptoArtifactUser{} = crypto_artifact_user, attrs \\ %{}) do
    CryptoArtifactUser.changeset(crypto_artifact_user, attrs)
  end
end
