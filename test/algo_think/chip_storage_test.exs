defmodule AlgoThink.ChipStorageTest do
  use AlgoThink.DataCase

  alias AlgoThink.ChipStorage

  describe "cryptoartifact_users" do
    alias AlgoThink.ChipStorage.CryptoArtifactUser

    import AlgoThink.ChipStorageFixtures

    @invalid_attrs %{}

    test "list_cryptoartifact_users/0 returns all cryptoartifact_users" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      assert ChipStorage.list_cryptoartifact_users() == [crypto_artifact_user]
    end

    test "get_crypto_artifact_user!/1 returns the crypto_artifact_user with given id" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      assert ChipStorage.get_crypto_artifact_user!(crypto_artifact_user.id) == crypto_artifact_user
    end

    test "create_crypto_artifact_user/1 with valid data creates a crypto_artifact_user" do
      valid_attrs = %{}

      assert {:ok, %CryptoArtifactUser{} = crypto_artifact_user} = ChipStorage.create_crypto_artifact_user(valid_attrs)
    end

    test "create_crypto_artifact_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ChipStorage.create_crypto_artifact_user(@invalid_attrs)
    end

    test "update_crypto_artifact_user/2 with valid data updates the crypto_artifact_user" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      update_attrs = %{}

      assert {:ok, %CryptoArtifactUser{} = crypto_artifact_user} = ChipStorage.update_crypto_artifact_user(crypto_artifact_user, update_attrs)
    end

    test "update_crypto_artifact_user/2 with invalid data returns error changeset" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      assert {:error, %Ecto.Changeset{}} = ChipStorage.update_crypto_artifact_user(crypto_artifact_user, @invalid_attrs)
      assert crypto_artifact_user == ChipStorage.get_crypto_artifact_user!(crypto_artifact_user.id)
    end

    test "delete_crypto_artifact_user/1 deletes the crypto_artifact_user" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      assert {:ok, %CryptoArtifactUser{}} = ChipStorage.delete_crypto_artifact_user(crypto_artifact_user)
      assert_raise Ecto.NoResultsError, fn -> ChipStorage.get_crypto_artifact_user!(crypto_artifact_user.id) end
    end

    test "change_crypto_artifact_user/1 returns a crypto_artifact_user changeset" do
      crypto_artifact_user = crypto_artifact_user_fixture()
      assert %Ecto.Changeset{} = ChipStorage.change_crypto_artifact_user(crypto_artifact_user)
    end
  end
end
