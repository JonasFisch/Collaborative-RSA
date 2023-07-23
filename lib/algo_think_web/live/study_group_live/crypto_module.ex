defmodule AlgoThinkWeb.StudyGroupLive.CryptoModule do
  alias AlgoThink.ChipStorage
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id="drag">
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

  def handle_event("encrypt", _params, socket) do
    zones = socket.assigns.data |> Enum.filter(fn drop_zone -> drop_zone.result == false end)

    # TODO: make this method depend on the type
    with {:ok, result} <- CryptoArtifacts.encrypt_message(
        socket.assigns.current_user.id,
        Enum.reduce(zones, %{}, fn zone, acc ->
          Map.put(acc, zone.expected_type, zone.crypto_artifact)
        end)
      ),
      {:ok, _crytpo_artifact_user} <- ChipStorage.create_crypto_artifact_user(%{
        user_id: socket.assigns.current_user.id,
        crypto_artifact_id: result.id,
        study_group_id: socket.assigns.study_group_id
      })
    do
      send(self(), %{topic: "add_new_chip", crypto_artifact: result, location: socket.assigns.type, drop_zone_id: "drop-zone-encryption-result"})
      {:noreply, socket}
    else
      {:error, changeset} ->
        errors = changeset.errors
        |> Enum.reduce(Map.new(), fn error, acc ->
          # transform error message to format: {field, error_message}
          {key, {msg, _other}} = error
          Map.put(acc, key, msg)
        end)

        {:noreply, socket |> assign(errors: errors)}
      _err ->
        IO.warn("uncatched error in crypto module")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("dropped", params, socket) do
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: "encryption"})
    {:noreply, socket}
  end
end
