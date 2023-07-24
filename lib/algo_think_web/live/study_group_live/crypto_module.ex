defmodule AlgoThinkWeb.StudyGroupLive.CryptoModule do
  alias AlgoThink.ChipStorage
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id={"crypo-module-#{@type}"}>
      <AlgoThinkWeb.Accordion.accordion header={@name} open>
        <div class="flex flex-col gap-4">
          <%= for field <- @data do %>
            <div class="flex flex-row justify-between items-center gap-4">
              <span class="w-2/6 font-medium">
                <%= field.name %>:
              </span>
              <AlgoThinkWeb.DropZone.drop_zone error={Map.get(@errors, field.expected_type)} placeholder={"#{field.placeholder}"} is_result={field.result} crypto_artifact={field.crypto_artifact} id={field.drop_zone_id} />
            </div>
          <% end %>
        </div>
        <div class="flex flex-row justify-end mt-4">
          <.button phx-click="encrypt" phx-target={@myself}><%= @action %></.button>
        </div>
      </AlgoThinkWeb.Accordion.accordion>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    zones_structure = case assigns.type do
      "encryption" -> [
        %{type: :message, name: "Message", placeholder: "Drop Message"},
        %{type: :public_key, name: "Encrypt with", placeholder: "Drop Public Key"},
        %{type: :result, name: "Encrypted Message"}
      ]
      "decryption" -> [
        %{type: :message, name: "Encrypted Message", placeholder: "Drop Message", encrypted: true},
        %{type: :private_key, name: "Decrypt with", placeholder: "Drop Private Key"},
        %{type: :result, name: "Message"}
      ]
      "sign" -> [
        %{type: :message, name: "Message", placeholder: "Drop Message"},
        %{type: :private_key, name: "Sign with", placeholder: "Drop Private Key"},
        %{type: :result, name: "Signature"}
      ]
      "verify" -> [
        %{type: :signature, name: "Signature", placeholder: "Drop Signature"},
        %{type: :message, name: "Message", placeholder: "Drop Message"},
        %{type: :public_key, name: "Public Key", placeholder: "Drop Public Key"},
        %{type: :result, name: "Valid"}
      ]
      _ -> raise("invalid type given in crypto module live component")
    end

    zones =
      zones_structure
      |> Enum.map(fn zone_structure ->
        zone_type = Map.get(zone_structure, :type)
        encrypted = Map.get(zone_structure, :encrypted)
        name = Map.get(zone_structure, :name)
        placeholder = Map.get(zone_structure, :placeholder, "result")
        is_result = zone_type == :result
        crypto_artifact = Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-#{assigns.type}-#{zone_type}" end)
        %{
          drop_zone_id: "drop-zone-#{assigns.type}-#{zone_type}",
          name: name,
          crypto_artifact: crypto_artifact,
          placeholder: placeholder,
          expected_type: zone_type,
          encrypted: encrypted,
          result: is_result
        }
      end)

    {:ok,
     socket
      |> assign(assigns)
      |> assign(:errors, %{})
      |> assign(:data, zones)
    }
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(data: [])}
  end

  defp action(type, current_user_id, crypto_artifact_map) do
    case type do
      "encryption" ->
        CryptoArtifacts.encrypt_message(
          current_user_id,
          crypto_artifact_map
        )
      "decryption" ->
        CryptoArtifacts.decrypt_message(
          crypto_artifact_map
        )
      "sign" ->
        CryptoArtifacts.create_signature(
          current_user_id,
          crypto_artifact_map
        )
      "verify" ->
        CryptoArtifacts.verify_message(
          crypto_artifact_map
        )
      _ -> IO.warn("invalid action given")
    end
  end

  defp post_action(type, current_user_id, result, study_group_id) do
    if type == "verify" do
      IO.inspect("post action verify")
      # TODO: mark message as verified / or not valid

      valid = if Map.get(result, :valid) do :valid else :invalid end

      updated_message = CryptoArtifacts.update_crypto_artifact(
        Map.get(result, :message),
        %{valid: valid}
      )

      IO.inspect(updated_message)

      valid = true

      {:ok, valid}
    else
      ChipStorage.create_crypto_artifact_user(%{
        user_id: current_user_id,
        crypto_artifact_id: result.id,
        study_group_id: study_group_id
      })
    end
  end

  def handle_event("encrypt", _params, socket) do
    zones = socket.assigns.data |> Enum.filter(fn drop_zone -> drop_zone.result == false end)

    current_user_id = socket.assigns.current_user.id
    crypto_artifact_map = Enum.reduce(zones, %{}, fn zone, acc ->
      Map.put(acc, zone.expected_type, zone.crypto_artifact)
    end)

    with {:ok, result} <- action(
        socket.assigns.type,
        current_user_id,
        crypto_artifact_map
      ),
      {:ok, _post_result} <- post_action(
        socket.assigns.type,
        current_user_id,
        result,
        socket.assigns.study_group_id
      )
    do
      if socket.assigns.type == "verify" do
        valid = Map.get(result, :valid)
        message = Map.get(result, :message)

        send(self(), %{topic: "mark_message_as_valid", message: message, valid: valid})
      else
        send(self(), %{topic: "add_new_chip", crypto_artifact: result, location: socket.assigns.type, drop_zone_id: "drop-zone-#{socket.assigns.type}-result"})
      end
      {:noreply, socket}
    else
      {:error, changeset} ->
        # transform error message to format: {field, error_message}
        errors = changeset.errors
        |> Enum.reduce(Map.new(), fn error, acc ->
          {key, {msg, _other}} = error
          Map.put(acc, key, msg)
        end)

        {:noreply, socket |> assign(errors: errors)}
      err ->
        IO.warn("uncatched error in crypto module")
        IO.inspect(err)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("dropped", params, socket) do
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: socket.assigns.type})
    {:noreply, socket}
  end
end
