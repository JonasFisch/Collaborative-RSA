defmodule AlgoThinkWeb.StudyGroupLive.Index do
  use AlgoThinkWeb, :live_view

  def mount(_params, _session, socket) do

    # clear text
    clear_text = "hallo"

    # generate keys
    {:ok, private_key} = ExPublicKey.generate_key(4096)
    {:ok, public_key} = ExPublicKey.public_key_from_private_key(private_key)

    # encrypt keys
    {:ok, cipher_text} = ExPublicKey.encrypt_public(clear_text, public_key)

    IO.inspect("cipher text: #{cipher_text}")

    {:ok, decrypted_text} = ExPublicKey.decrypt_private(cipher_text, private_key)

    IO.inspect("decrypted text: #{decrypted_text}")

    {:ok, socket}
  end

  # defp apply_action(socket, :index, _params) do
  #   socket
  #   |> assign(:page_title, "Listing Classroom")
  #   |> assign(:classroom, nil)
  # end
end
