defmodule AlgoThinkWeb.StudyGroupLive.EncryptionModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id="drag">
      <AlgoThinkWeb.Accordion.accordion header={"Encryption"} open>
        <.crypto_module name="Encryption" fields={@data} />
      </AlgoThinkWeb.Accordion.accordion>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
      |> assign(assigns)
      |> assign(:errors, [])
      |> assign(:data, [
        %{drop_zone_id: "drop-zone-encryption-message", name: "Plain Message", crypto_artifact: Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-encryption-message" end), placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
        %{drop_zone_id: "drop-zone-encryption-public-key", name: "Encrypt with", crypto_artifact: Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "drop-zone-encryption-public-key" end), placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
        %{drop_zone_id: "drop-zone-encryption-result", name: "Encrypted Message", crypto_artifact: nil, placeholder: "Result", expected_type: :message, encrypted: true, result: true}
      ])
    }
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(data: [])}
  end

  @impl true
  def handle_event("dropped", params, socket) do
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: "encryption"})
    {:noreply, socket}
  end
end
