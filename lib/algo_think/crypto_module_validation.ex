defmodule AlgoThink.CryptoModuleValidation do

  @available_types [:private_key, :public_key, :signature, :message]

  defp get_attribute(crypto_artifact, attribute) do
    if (crypto_artifact == nil) do
      nil
    else
      Map.get(crypto_artifact, attribute)
    end
  end

  defp validate_encrypted(changeset, field, encrypted?) do
    IO.inspect(encrypted?)
    if not !!encrypted? do
      Ecto.Changeset.add_error(changeset, :message, "encrypted message needed")
    else
      changeset
    end
  end

  defp validate_unencrypted(changeset, field, encrypted?) do
    if !!encrypted? do
      Ecto.Changeset.add_error(changeset, :message, "unencrypted message needed")
    else
      changeset
    end
  end

  def changeset_encryption(%{message: message, public_key: public_key}) do
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
    |> validate_unencrypted(:message, get_attribute(message, :encrypted))
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
    |> validate_encrypted(:message, get_attribute(message, :encrypted))
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
    |> validate_unencrypted(:message, get_attribute(message, :encrypted))
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
    |> validate_unencrypted(:message, get_attribute(message, :encrypted))
  end
end
