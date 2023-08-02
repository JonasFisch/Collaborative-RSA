defmodule AlgoThinkWeb.StudyGroupLive.StorageModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-3/12">
      <.container class="w-full relative" phx-hook="drag" id="storage-drag" title="Storage">
        <.drag_modal :if={@drag_origin != "storage"} primary_text="Put in storage" secondary_text="Drop to place chip in storage" />

        <div class={[
          "h-full",
          if @drag_origin != "storage" do "disable-pointer-events-dragging" end
        ]}>
          <div class="h-full p-2 overflow-y-scroll">
            <%= for {{owner}, crypto_artifacts} <- @grouped_artifacts do %>
              <div class="bg-slate-100 mb-2">
                <h3 class="text-lg font-bold m-1">
                  <%= owner %>
                </h3>
                <%= for crypto_artifact <- crypto_artifacts do %>
                  <.chip id={crypto_artifact.id} type={crypto_artifact.type} name={crypto_artifact.owner.name} signed={crypto_artifact.signed} encrypted={crypto_artifact.encrypted} valid={crypto_artifact.valid}  />
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </.container>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do

    artifacts = Map.get(assigns, :storage_artifacts, [])

    grouped_artifacts = artifacts
      |> Enum.group_by(&{&1.owner.name})
      |> Enum.sort(fn {{key1}, _artifact1}, {{_key2}, _artifact2} ->
        # always show current user on top
        if (key1 == assigns.current_user.name) do
          true
        else
          false
        end
      end)
      |> Enum.map(fn {{key1}, artifact1} = element ->
        # mark current user
        if (key1 == assigns.current_user.name) do
          {{"#{key1} (You)"}, artifact1}
        else
          element
        end
      end)

    {:ok, socket
      |> assign(assigns)
      |> assign(:grouped_artifacts, grouped_artifacts)
    }
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
