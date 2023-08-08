defmodule AlgoThinkWeb.StudyGroupLive.Index do
  alias AlgoThink.CryptoModuleValidation
  alias AlgoThink.CryptoArtifacts
  alias AlgoThink.ChipStorage
  alias AlgoThink.ChatMessages
  alias AlgoThink.Classrooms

  use AlgoThinkWeb, :live_view

  @impl true
  def mount(%{"id" => classroom_id, "study_group_id" => study_group_id}, _session, socket) do

    AlgoThinkWeb.Endpoint.subscribe("study_group_#{study_group_id}")
    AlgoThinkWeb.Endpoint.subscribe("classroom")

    send(self(), "load_messages")
    send(self(), "load_users_chips")

    {:ok, socket |>
      assign(
        crypto_artifacts: [],
        chat_messages: [],
        study_group_id: study_group_id,
        classroom_id: classroom_id,
        open_accordion: "key_generation",
        drag_origin: "storage",
        state: Classrooms.get_classroom!(classroom_id) |> Map.get(:state),
        page_title: "Edit Classroom",
        chat_errors: [],
        task_done: false,
        task_modal_open: true
      ),
      layout: {AlgoThinkWeb.Layouts, :game},
    }
  end

  # EVENTS

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

  def handle_event("error_modal_ok_pressed", _params, socket) do
    {:noreply, socket |> assign(:chat_errors, [])}
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

   # handle drop on chat
   @impl true
  def handle_event("dropped", params, socket) do
    crypto_artifact_id = Map.get(params, "draggedId")
    crypto_artifact = CryptoArtifacts.get_crypto_artifact!(crypto_artifact_id)

    # create new messsage with artifact attached
    with  {:ok, _changeset} <- CryptoModuleValidation.changeset_encrypted_message(Map.from_struct(crypto_artifact)),
          {:ok, new_message} <- ChatMessages.create_chat_message(%{
            text: "",
            author_id: socket.assigns.current_user.id,
            study_group_id: socket.assigns.study_group_id,
            attachment_id: crypto_artifact_id
          })
    do
      {:noreply, socket
        |> assign(chat_messages: socket.assigns.chat_messages ++ [new_message])
      }
    else
      {:error, changeset} ->

        # extract error message
        errors = changeset.errors
        |> Enum.reduce([], fn error, acc ->
          {_key, {msg, _other}} = error
          acc ++ [msg]
        end)

        IO.inspect(errors)

        {:noreply, socket |> assign(chat_errors: errors)}
    end

  end

  def handle_event("close_task_modal", params, socket) do
    {:noreply, socket |> assign(task_modal_open: false)}
  end

  #  INFOS

  def handle_info(%{topic: "classroom", event: event, payload: _payload}, socket) do
    case event do
      "state_update" -> {:noreply, socket |> redirect(to: ~p"/classroom/#{socket.assigns.classroom_id}/studygroup/#{socket.assigns.study_group_id}")}
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{topic: topic, event: event, payload: payload}, socket) do
    if (topic == "study_group_#{socket.assigns.study_group_id}") do
      case event do
        "new_message" -> {:noreply, socket |> assign(chat_messages: socket.assigns.chat_messages ++ [payload])}
        _ -> {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_info("load_messages", socket) do
    chat_messages = ChatMessages.list_chat_messages(socket.assigns.study_group_id)
    {:noreply, socket |> assign(chat_messages: chat_messages)}
  end

  def handle_info(%{topic: "update_chip_location", dragged_id: dragged_id, drop_zone_id: drop_zone_id, location: location}, socket) do
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

  def handle_info(%{topic: "task_done"}, socket) do
    {:noreply, socket |> assign(task_done: true)}
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

    {:noreply, socket
      |> assign(crypto_artifacts: crypto_artifacts)
    }
  end

  def handle_info("load_users_chips", socket) do
    users_crypo_artifacts = ChipStorage.list_cryptoartifact_for_user(socket.assigns.current_user.id, socket.assigns.study_group_id)
    users_crypo_artifacts = users_crypo_artifacts |> Enum.map(fn artifact -> artifact |> Map.put(:location, "storage") |> Map.put(:location_id, nil) end)
    {:noreply, socket |> assign(crypto_artifacts: users_crypo_artifacts)}
  end

  def handle_info(%{topic: "start_drag", params: _params, origin: origin}, socket) do
    {:noreply, socket |> assign(drag_origin: origin)}
  end

  def handle_info(%{topic: "end_drag", params: _params}, socket) do
    # needed to fix bugs
    {:noreply, socket |> assign(drag_origin: "storage")}
  end
end
