defmodule AlgoThinkWeb.StudyGroupLive.StorageModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id="storage-drag" class="h-full ">
      <div class="drop-zone h-full border-2 rounded-md border-dashed p-2 phx-dragging:border-gray-300 phx-dragging:bg-gray-50 overflow-y-scroll">
        <%= for crypto_artifact <- @storage_artifacts do %>
          <.chip id={crypto_artifact.id} type={crypto_artifact.type} name={crypto_artifact.owner.name} signed={crypto_artifact.signed} encrypted={crypto_artifact.encrypted} />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(data: [])}
  end

  @impl true
  def handle_event("dropped", params, socket) do
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: "storage"})
    {:noreply, socket}
  end
end
