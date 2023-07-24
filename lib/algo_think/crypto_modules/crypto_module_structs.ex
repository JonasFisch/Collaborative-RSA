defmodule AlgoThink.CryptoModules.EncryptionModuleStruct do
  defstruct [:message, :public_key]
end

defmodule AlgoThink.CryptoModules.DecryptionModuleStruct do
  defstruct [:message, :private_key]
end

defmodule AlgoThink.CryptoModules.SignModuleStruct do
  defstruct [:message, :private_key]
end

defmodule AlgoThink.CryptoModules.VerifyModuleStruct do
  defstruct [:signature, :message, :public_key]
end
