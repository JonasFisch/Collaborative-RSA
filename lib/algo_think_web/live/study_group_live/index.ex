defmodule AlgoThinkWeb.StudyGroupLive.Index do
  alias AlgoThink.ChatMessages
  use AlgoThinkWeb, :live_view

  def mount(%{"id" => _classroom_id, "study_group_id" => study_group_id}, _session, socket) do

    AlgoThinkWeb.Endpoint.subscribe("study_group_#{study_group_id}")

    # clear_text = "hallo"

    # # generate keys
    # {:ok, private_key} = ExPublicKey.generate_key(4096)
    # {:ok, public_key} = ExPublicKey.public_key_from_private_key(private_key)

    # # encrypt message
    # {:ok, cipher_text} = ExPublicKey.encrypt_public(clear_text, public_key)
    # IO.inspect("cipher text: #{cipher_text}")

    # # sign encrypted
    # {:ok, signature} = ExPublicKey.sign(clear_text, private_key)

    # # decrypt
    # {:ok, decrypted_text} = ExPublicKey.decrypt_private(cipher_text, private_key)
    # IO.inspect("decrypted text: #{decrypted_text}")

    # # verify
    # {:ok, valid} = ExPublicKey.verify(decrypted_text, signature, public_key)
    # IO.inspect("valid: #{valid}")
    send(self(), "load_messages")

    # key creation
    # {:ok, private_key} = AlgoThink.CryptoArtifacts.create_private_key(socket.assigns.current_user.id)
    # {:ok, public_key} = AlgoThink.CryptoArtifacts.create_public_key(socket.assigns.current_user.id, private_key.id)

    # # encryption
    {:ok, message} = AlgoThink.CryptoArtifacts.create_message(socket.assigns.current_user.id, "Random Message")
    # {:ok, encrypted_message} = AlgoThink.CryptoArtifacts.encrypt_message(socket.assigns.current_user.id, message.id, public_key.id)
    # {:ok, signature} = AlgoThink.CryptoArtifacts.create_signature(socket.assigns.current_user.id, message.id, private_key.id)

    # # decryption and validation
    # {:ok, decrypted_message} = AlgoThink.CryptoArtifacts.decrypt_message(encrypted_message.id, private_key.id)
    # {:ok, valid} = AlgoThink.CryptoArtifacts.verify_message(decrypted_message.id, signature.id, public_key.id)
    # IO.inspect(valid)

    # # mark decrypted as verified
    # if (valid) do
    #   AlgoThink.CryptoArtifacts.mark_message_as_verified(decrypted_message.id)
    # end

    {:ok, socket |> assign(chat_messages: [], study_group_id: study_group_id, crypoartifact: message)}
  end

  def handle_info(%{topic: topic, event: "new_message", payload: new_message}, socket) do
    if (topic == "study_group_#{socket.assigns.study_group_id}") do
      {:noreply, socket |> assign(chat_messages: socket.assigns.chat_messages ++ [new_message])}
    else
      {:noreply, socket}
    end
  end

  def handle_event("send_message", params, socket) do
    with {:ok, new_message} <- ChatMessages.create_chat_message(%{text: params["text"], author_id: socket.assigns.current_user.id, study_group_id: socket.assigns.study_group_id}) do
      {:noreply, socket
        |> assign(chat_messages: socket.assigns.chat_messages ++ [new_message])
      }
    else
      {:error, _changeset} -> {:noreply, socket}
    end
  end

  def handle_info("load_messages", socket) do
    chat_messages = ChatMessages.list_chat_messages(socket.assigns.study_group_id)
    {:noreply, socket |> assign(chat_messages: chat_messages)}
  end


  # defp apply_action(socket, :index, _params) do
  #   socket
  #   |> assign(:page_title, "Listing Classroom")
  #   |> assign(:classroom, nil)
  # end
end
