defmodule AlgoThinkWeb.StudyGroupLive.EncryptionModule do
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

    if not Enum.member?(["encryption", "decryption", "sign", "verify"], assigns.type) do
      raise("invalid type given in crypto module live component")
    end

    # TODO: generate zones dynamically depending on input Enum variable
    zones = [
      %{drop_zone_id: "drop-zone-encryption-message", name: "Plain Message", crypto_artifact: Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-encryption-message" end), placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
      %{drop_zone_id: "drop-zone-encryption-public-key", name: "Encrypt with", crypto_artifact: Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-encryption-public-key" end), placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
      %{drop_zone_id: "drop-zone-encryption-result", name: "Encrypted Message", crypto_artifact: Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-encryption-result" end), placeholder: "Result", expected_type: :message, encrypted: true, result: true}
    ]

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
      err ->
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
