defmodule AlgoThinkWeb.StudyGroupLive.Index do
  alias AlgoThink.CryptoArtifacts
  alias AlgoThink.ChipStorage
  alias AlgoThink.ChatMessages
  use AlgoThinkWeb, :live_view

  @impl true
  def mount(%{"id" => _classroom_id, "study_group_id" => study_group_id}, _session, socket) do

    AlgoThinkWeb.Endpoint.subscribe("study_group_#{study_group_id}")

    # create message
    # {:ok, message} = AlgoThink.CryptoArtifacts.create_message(socket.assigns.current_user.id, "Random Message")
    # ChipStorage.create_crypto_artifact_user(%{user_id: socket.assigns.current_user.id, study_group_id: study_group_id, crypto_artifact_id: message.id })

    send(self(), "load_messages")
    send(self(), "load_users_chips")

    {:ok, socket |>
      assign(
        crypto_artifacts: [],
        chat_messages: [],
        study_group_id: study_group_id,
        open_accordion: "none",
        drag_origin: "storage"
      ),
      layout: {AlgoThinkWeb.Layouts, :game}
    }
  end

  @impl true
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
    {:noreply, socket |> assign(
      open_accordion: Map.get(params, "type"),
      crypto_artifacts: Enum.map(socket.assigns.crypto_artifacts, fn crypto_artifact ->
        # put all chips back into the storage
        Map.put(crypto_artifact, :location, "storage")
      end)
    )}
  end

  def handle_event("add_attachment_to_storage", params, socket) do
    attachment_id = Map.get(params, "attachment-id")

    # add crypto artifact to storage
    with {:ok, _crypto_artifact_user}<- ChipStorage.create_crypto_artifact_user(%{user_id: socket.assigns.current_user.id, study_group_id: socket.assigns.study_group_id, crypto_artifact_id: attachment_id }) do
      attachment = CryptoArtifacts.get_crypto_artifact!(attachment_id)
      send(self(), %{topic: "add_new_chip", crypto_artifact: attachment, location: "storage", drop_zone_id: ""})
      {:noreply, socket}
    else
      {:error, _err} ->
        {:noreply, socket |> put_flash(:info, "Chip already added")}
    end
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

  # handle drop on chat
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

  def handle_info(%{topic: "start_drag", params: _params, origin: origin}, socket) do
    {:noreply, socket |> assign(drag_origin: origin)}
  end

  def handle_info(%{topic: "end_drag", params: _params}, socket) do
    # needed to fix bugs
    {:noreply, socket |> assign(drag_origin: "storage")}
  end
end
