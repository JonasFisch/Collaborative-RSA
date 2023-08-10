defmodule AlgoThink.CryptoModuleValidation do
alias AlgoThink.CryptoArtifacts

  @available_types [:private_key, :public_key, :signature, :message]

  defp get_attribute(crypto_artifact, attribute) do
    if (crypto_artifact == nil) do
      nil
    else
      Map.get(crypto_artifact, attribute)
    end
  end

  defp validate_encrypted(changeset, encrypted?, validate \\ true) do
    if not !!encrypted? and validate do
      Ecto.Changeset.add_error(changeset, :message, "encrypted message needed")
    else
      changeset
    end
  end

  defp validate_unencrypted(changeset, encrypted?) do
    if !!encrypted? do
      Ecto.Changeset.add_error(changeset, :message, "unencrypted message needed")
    else
      changeset
    end
  end

  defp validate_public_key_self_encrypt(changeset, public_key_owner_id, current_user_id) do
    if public_key_owner_id == current_user_id do
      Ecto.Changeset.add_error(changeset, :public_key, "use public key from another person")
    else
      changeset
    end
  end

  def changeset_encryption(%{message: message, public_key: public_key}, current_user_id) do
    encryption_module = %AlgoThink.CryptoModules.EncryptionModuleStruct{}
    types = %{
      message: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types),
      public_key: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types)
    }

    params = %{message: get_attribute(message, :type), public_key: get_attribute(public_key, :type)}

    {encryption_module, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message, :public_key])
    |> Ecto.Changeset.validate_inclusion(:message, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:public_key, [:public_key], message: "public key required")
    |> validate_public_key_self_encrypt(get_attribute(public_key, :owner_id), current_user_id)
    |> validate_unencrypted(get_attribute(message, :encrypted))
  end

  def changeset_decryption(%{message: message, private_key: private_key}) do
    decryption_module = %AlgoThink.CryptoModules.DecryptionModuleStruct{}
    types = %{
      message: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types),
      private_key: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types)
    }

    params = %{message: get_attribute(message, :type), private_key: get_attribute(private_key, :type)}

    {decryption_module, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message, :private_key])
    |> Ecto.Changeset.validate_inclusion(:message, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:private_key, [:private_key], message: "private key required")
    |> validate_encrypted(get_attribute(message, :encrypted))
  end

  def changeset_sign(%{message: message, private_key: private_key}) do
    sign_module = %AlgoThink.CryptoModules.SignModuleStruct{}
    types = %{
      message: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types),
      private_key: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types)
    }

    params = %{message: get_attribute(message, :type), private_key: get_attribute(private_key, :type)}

    {sign_module, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message, :private_key])
    |> Ecto.Changeset.validate_inclusion(:message, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:private_key, [:private_key], message: "private key required")
    |> validate_unencrypted(get_attribute(message, :encrypted))
  end

  def changeset_verify(%{message: message, signature: signature, public_key: public_key}) do
    sign_module = %AlgoThink.CryptoModules.VerifyModuleStruct{}
    types = %{
      message: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types),
      signature: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types),
      public_key: Ecto.ParameterizedType.init(Ecto.Enum, values: @available_types)
    }

    params = %{message: get_attribute(message, :type), signature: get_attribute(signature, :type), public_key: get_attribute(public_key, :type)}

    {sign_module, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message, :signature, :public_key])
    |> Ecto.Changeset.validate_inclusion(:message, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:public_key, [:public_key], message: "public key required")
    |> Ecto.Changeset.validate_inclusion(:signature, [:signature], message: "signature required")
    |> validate_unencrypted(get_attribute(message, :encrypted))
  end

  def changeset_solution(message, expected_user_id) do
    {owner_id, _} = Integer.parse(expected_user_id)
    %CryptoArtifacts.CryptoArtifact{}
    |> Ecto.Changeset.cast(message, [:type, :content, :encrypted, :signed, :owner_id, :valid])
    |> Ecto.Changeset.validate_inclusion(:type, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:owner_id, [owner_id], message: "wrong author")
    |> validate_unencrypted(get_attribute(message, :encrypted))
  end

  def changeset_solution_with_signature(message, expected_user_id) do
    IO.inspect(message)
    {owner_id, _} = Integer.parse(expected_user_id)
    %CryptoArtifacts.CryptoArtifact{}
    |> Ecto.Changeset.cast(message, [:type, :content, :encrypted, :signed, :owner_id, :valid])
    |> Ecto.Changeset.validate_required([:valid], message: "message must be verified!")
    |> Ecto.Changeset.validate_inclusion(:valid, [:valid], message: "message must be verified!")
    |> Ecto.Changeset.validate_inclusion(:type, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:owner_id, [owner_id], message: "wrong author")
    |> validate_unencrypted(get_attribute(message, :encrypted))
  end

  def validate_if_true(changeset, validator ,condition) do
    if (condition) do
      validator
    else
      changeset
    end
  end

  def changeset_encrypted_message(message) do
    changeset = %CryptoArtifacts.CryptoArtifact{}
    |> Ecto.Changeset.cast(message, [:type, :content, :encrypted, :signed, :owner_id, :valid])
    |> validate_encrypted(get_attribute(message, :encrypted), message.type == :message) # prevent sending unencrypted message
    # prevent sending private key
    |> Ecto.Changeset.validate_exclusion(:type, [:private_key], message: "don't ever send your private key to others! People who have access to your private key can decrypt the secret messages that were encrypted with your public key!")
    if (length(changeset.errors) > 0) do
      {:error, changeset}
    else
      {:ok, changeset}
    end
  end
end
