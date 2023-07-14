defmodule AlgoThink.CryptoArtifactsTest do
  use AlgoThink.DataCase

  alias AlgoThink.CryptoArtifacts

  describe "crypto_artifacts" do
    alias AlgoThink.CryptoArtifacts.CryptoArtifact

    import AlgoThink.CryptoArtifactsFixtures

    @invalid_attrs %{content: nil, encrypted: nil, type: nil}

    test "list_crypto_artifacts/0 returns all crypto_artifacts" do
      crypto_artifact = crypto_artifact_fixture()
      assert CryptoArtifacts.list_crypto_artifacts() == [crypto_artifact]
    end

    test "get_crypto_artifact!/1 returns the crypto_artifact with given id" do
      crypto_artifact = crypto_artifact_fixture()
      assert CryptoArtifacts.get_crypto_artifact!(crypto_artifact.id) == crypto_artifact
    end

    test "create_crypto_artifact/1 with valid data creates a crypto_artifact" do
      valid_attrs = %{content: "some content", encrypted: true, type: :private_key}

      assert {:ok, %CryptoArtifact{} = crypto_artifact} = CryptoArtifacts.create_crypto_artifact(valid_attrs)
      assert crypto_artifact.content == "some content"
      assert crypto_artifact.encrypted == true
      assert crypto_artifact.type == :private_key
    end

    test "create_crypto_artifact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CryptoArtifacts.create_crypto_artifact(@invalid_attrs)
    end

    test "update_crypto_artifact/2 with valid data updates the crypto_artifact" do
      crypto_artifact = crypto_artifact_fixture()
      update_attrs = %{content: "some updated content", encrypted: false, type: :public_key}

      assert {:ok, %CryptoArtifact{} = crypto_artifact} = CryptoArtifacts.update_crypto_artifact(crypto_artifact, update_attrs)
      assert crypto_artifact.content == "some updated content"
      assert crypto_artifact.encrypted == false
      assert crypto_artifact.type == :public_key
    end

    test "update_crypto_artifact/2 with invalid data returns error changeset" do
      crypto_artifact = crypto_artifact_fixture()
      assert {:error, %Ecto.Changeset{}} = CryptoArtifacts.update_crypto_artifact(crypto_artifact, @invalid_attrs)
      assert crypto_artifact == CryptoArtifacts.get_crypto_artifact!(crypto_artifact.id)
    end

    test "delete_crypto_artifact/1 deletes the crypto_artifact" do
      crypto_artifact = crypto_artifact_fixture()
      assert {:ok, %CryptoArtifact{}} = CryptoArtifacts.delete_crypto_artifact(crypto_artifact)
      assert_raise Ecto.NoResultsError, fn -> CryptoArtifacts.get_crypto_artifact!(crypto_artifact.id) end
    end

    test "change_crypto_artifact/1 returns a crypto_artifact changeset" do
      crypto_artifact = crypto_artifact_fixture()
      assert %Ecto.Changeset{} = CryptoArtifacts.change_crypto_artifact(crypto_artifact)
    end
  end
end
