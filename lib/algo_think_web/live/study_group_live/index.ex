defmodule AlgoThinkWeb.StudyGroupLive.Index do
  alias AlgoThink.CryptoArtifacts
  alias AlgoThink.ChipStorage
  alias AlgoThink.ChatMessages
  use AlgoThinkWeb, :live_view

  def mount(%{"id" => _classroom_id, "study_group_id" => study_group_id}, _session, socket) do

    AlgoThinkWeb.Endpoint.subscribe("study_group_#{study_group_id}")

    # crypto_modules = %{
    #   encryption: [
    #     %{module: :encryption, drop_zone_id: "drop-zone-encryption-message", name: "Plain Message", crypto_artifact: nil, placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
    #     %{module: :encryption, drop_zone_id: "drop-zone-encryption-public-key", name: "Encrypt with", crypto_artifact: nil, placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
    #     %{module: :encryption, drop_zone_id: "drop-zone-encryption-result", name: "Encrypted Message", crypto_artifact: nil, placeholder: "Result", expected_type: :message, encrypted: true, result: true}
    #   ],
    # }

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
    # {:ok, message} = AlgoThink.CryptoArtifacts.create_message(socket.assigns.current_user.id, "Random Message")
    # {:ok, encrypted_message} = AlgoThink.CryptoArtifacts.encrypt_message(socket.assigns.current_user.id, message.id, public_key.id)
    # {:ok, signature} = Alphx-click="add_key_to_storage" phx-target={@myself}goThink.CryptoArtifacts.create_signature(socket.assigns.current_user.id, message.id, private_key.id)

    # # decryption and validation
    # {:ok, decrypted_message} = AlgoThink.CryptoArtifacts.decrypt_message(encrypted_message.id, private_key.id)
    # {:ok, valid} = AlgoThink.CryptoArtifacts.verify_message(decrypted_message.id, signature.id, public_key.id)
    # IO.inspect(valid)

    # # mark decrypted as verified
    # if (valid) do
    #   AlgoThink.CryptoArtifacts.mark_message_as_verified(decrypted_message.id)
    # end

    # ChipStorage.create_crypto_artifact_user(%{user_id: socket.assigns.current_user.id, study_group_id: study_group_id, crypto_artifact_id: message.id })

    # users_crypo_artifacts = ChipStorage.list_cryptoartifact_for_user(socket.assigns.current_user.id, study_group_id)
    send(self(), "load_users_chips")

    # IO.inspect(users_crypo_artifacts)

    {:ok, socket |>
      assign(
        crypto_artifacts: [],
        chat_messages: [],
        study_group_id: study_group_id,
        open_accordion: "encryption"
      ),
      layout: {AlgoThinkWeb.Layouts, :game}
    }
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

  def handle_event("accordion_toggled", params, socket) do
    {:noreply, socket |> assign(open_accordion: Map.get(params, "type"))}
  end

  def handle_event("add_attachment_to_storage", params, socket) do
    attachment_id = Map.get(params, "attachment-id")
    IO.inspect(attachment_id)

    # TODO: check if there is already a connnection (add unique constrain in db! and catch error!)
    with {:ok, crypto_artifact_user}<- ChipStorage.create_crypto_artifact_user(%{user_id: socket.assigns.current_user.id, study_group_id: socket.assigns.study_group_id, crypto_artifact_id: attachment_id }) do
      attachment = CryptoArtifacts.get_crypto_artifact!(attachment_id)
      send(self(), %{topic: "add_new_chip", crypto_artifact: attachment, location: "storage", drop_zone_id: ""})
    else
      # TODO: unique entry contrain!
      {:error, err} -> IO.inspect(err)
    end

    {:noreply, socket}
  end

  def handle_info("load_messages", socket) do
    chat_messages = ChatMessages.list_chat_messages(socket.assigns.study_group_id)
    {:noreply, socket |> assign(chat_messages: chat_messages)}
  end

  def handle_info(%{topic: "update_chip_location", dragged_id: dragged_id, drop_zone_id: drop_zone_id, location: location}, socket) do

    IO.inspect(location)

    artifacts = (socket.assigns.crypto_artifacts)
    |> Enum.map(fn artifact ->
      if artifact.id == dragged_id do
        %{artifact | location_id: drop_zone_id, location: location}
      else
        # remove chip that is already in drop box
        if (artifact.location_id == drop_zone_id) do
          %{artifact | location_id: "storage", location: "storage"}
        else
          artifact
        end
      end
    end)
    {:noreply, socket |> assign(
      crypto_artifacts: artifacts
    )}
  end

  def handle_info(%{topic: "add_new_chip", crypto_artifact: crypto_artifact, location: location, drop_zone_id: drop_zone_id}, socket) do
    IO.inspect("in add new chip")

    crypto_artifact = crypto_artifact
    |> Map.put(:location, location)
    |> Map.put(:location_id, drop_zone_id)

    {:noreply, socket |> assign(crypto_artifacts: socket.assigns.crypto_artifacts ++ [crypto_artifact])}
  end

  def handle_info(%{topic: "mark_message_as_valid", message: message, valid: valid?}, socket) do
    IO.inspect("in mark_message_as_valid")

    crypto_artifacts = socket.assigns.crypto_artifacts
    |> Enum.map(fn artifact ->
      if (artifact.id == message.id) do
        %{artifact | valid: if valid? do :valid else :invalid end}
      else
        artifact
      end
    end)

    {:noreply, socket |> assign(crypto_artifacts: crypto_artifacts)}
  end

  def handle_info("load_users_chips", socket) do
    users_crypo_artifacts = ChipStorage.list_cryptoartifact_for_user(socket.assigns.current_user.id, socket.assigns.study_group_id)
    users_crypo_artifacts = users_crypo_artifacts |> Enum.map(fn artifact -> artifact |> Map.put(:location, "storage") |> Map.put(:location_id, nil) end)
    {:noreply, socket |> assign(storage_artifacts: users_crypo_artifacts, crypto_artifacts: users_crypo_artifacts)}
  end

  @impl true
  def handle_event("dropped", params, socket) do
    crypto_artifact_id = Map.get(params, "draggedId")
    crypto_artifact = CryptoArtifacts.get_crypto_artifact!(crypto_artifact_id)

    # TODO: do some checkings if item can be dropped here!!!

    # create new messsage with artifact attached
    with {:ok, new_message} <- ChatMessages.create_chat_message(%{
        text: "",
        author_id: socket.assigns.current_user.id,
        study_group_id: socket.assigns.study_group_id,
        attachment_id: crypto_artifact_id
    }) do
      {:noreply, socket
        |> assign(chat_messages: socket.assigns.chat_messages ++ [new_message])
      }
    else
      {:error, _changeset} ->
        IO.inspect("error")
        {:noreply, socket}
    end
  end
end
