defmodule AlgoThink.CryptoArtifactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AlgoThink.CryptoArtifacts` context.
  """

  @doc """
  Generate a crypto_artifact.
  """
  def crypto_artifact_fixture(attrs \\ %{}) do
    {:ok, crypto_artifact} =
      attrs
      |> Enum.into(%{
        content: "some content",
        encrypted: true,
        type: :private_key
      })
      |> AlgoThink.CryptoArtifacts.create_crypto_artifact()

    crypto_artifact
  end
end
