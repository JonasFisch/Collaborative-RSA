defmodule AlgoThinkWeb.StudyGroupLive.StorageModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-3/12">
      <.container class="w-full p-7 relative" phx-hook="drag" id="storage-drag">
        <div class="drop-zone h-full w-full overflow-y-scroll">
          <.drag_modal :if={@drag_origin != "storage"} primary_text="Put in storage" secondary_text="Drop to place chip in storage" />

          <div class={[
            "h-full",
            if @drag_origin != "storage" do "disable-pointer-events-dragging" end
          ]}>
            <div class="h-full p-2">
              <%= for crypto_artifact <- @storage_artifacts do %>
                <.chip id={crypto_artifact.id} type={crypto_artifact.type} name={crypto_artifact.owner.name} signed={crypto_artifact.signed} encrypted={crypto_artifact.encrypted} valid={crypto_artifact.valid}  />
              <% end %>
            </div>
          </div>
        </div>
      </.container>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("dropped", params, socket) do
    send(self(), %{topic: "update_chip_location", dragged_id: params["draggedId"], drop_zone_id: params["dropzoneId"], location: "storage"})
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_drag", params, socket) do
    send(self(), %{topic: "start_drag", params: params, origin: "storage"})
    {:noreply, socket}
  end

  def handle_event("end_drag", params, socket) do
    send(self(), %{topic: "end_drag", params: params})
    {:noreply, socket}
  end
end
