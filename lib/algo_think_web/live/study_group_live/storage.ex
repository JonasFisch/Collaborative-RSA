defmodule AlgoThinkWeb.StudyGroupLive.StorageModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id="storage-drag" class="h-96">
      <div class="drop-zone h-full">
        <%= for crypto_artifact <- @storage_artifacts do %>
          <.chip id={crypto_artifact.id} type={crypto_artifact.type} name={crypto_artifact.owner.name} signed={crypto_artifact.signed} />
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
    IO.inspect("Dropped")
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: "storage"})
    {:noreply, socket}
  end
end
