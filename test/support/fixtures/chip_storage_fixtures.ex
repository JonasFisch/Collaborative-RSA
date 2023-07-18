defmodule AlgoThink.ChipStorageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AlgoThink.ChipStorage` context.
  """

  @doc """
  Generate a crypto_artifact_user.
  """
  def crypto_artifact_user_fixture(attrs \\ %{}) do
    {:ok, crypto_artifact_user} =
      attrs
      |> Enum.into(%{

      })
      |> AlgoThink.ChipStorage.create_crypto_artifact_user()

    crypto_artifact_user
  end
end
