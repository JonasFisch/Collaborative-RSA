defmodule AlgoThink.CryptoModuleValidation do

  defp get_type(crypto_artifact) do
    if (crypto_artifact == nil) do
      nil
    else
      Map.get(crypto_artifact, :type)
    end
  end

  def changeset_encryption(%{message: message, public_key: public_key}) do
    encryption_module = %AlgoThink.CryptoModules.EncryptionModuleStruct{}
    types = %{
      message: Ecto.ParameterizedType.init(Ecto.Enum, values: [:private_key, :public_key, :signature, :message]),
      public_key: Ecto.ParameterizedType.init(Ecto.Enum, values: [:private_key, :public_key, :signature, :message])
    }

    params = %{message: get_type(message), public_key: get_type(public_key)}

    {encryption_module, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
    |> Ecto.Changeset.validate_required([:message, :public_key])
    |> Ecto.Changeset.validate_inclusion(:message, [:message], message: "message required")
    |> Ecto.Changeset.validate_inclusion(:public_key, [:public_key], message: "public key required")
  end
end
