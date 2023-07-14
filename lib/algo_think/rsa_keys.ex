defmodule AlgoThink.RSAKeys do
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
