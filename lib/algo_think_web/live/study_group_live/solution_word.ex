defmodule AlgoThinkWeb.StudyGroupLive.SolutionWord do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full mt-4" phx-hook="drag" id="solution-module">
      <div class="flex justify-between items-center">
        <%= for number <- 0..3 do %>
          <div class="w-1/5">
            <.drop_zone class="phx-dragging:bg-gray-100" id={"result-#{number}"} crypto_artifact={Enum.find(@crypto_artifacts, fn artifact -> artifact.location_id == "result-#{number}" end)}></.drop_zone>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("dropped", params, socket) do
    crypto_artifact_id = Map.get(params, "draggedId")
    # TODO: validate chip that was dropped and give error message



    send(self(), %{topic: "update_chip_location", dragged_id: crypto_artifact_id, drop_zone_id: params["dropzoneId"], location: "solution_word"})
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_drag", params, socket) do
    send(self(), %{topic: "start_drag", params: params, origin: socket.assigns.type})
    {:noreply, socket}
  end

  def handle_event("end_drag", params, socket) do
    send(self(), %{topic: "end_drag", params: params})
    {:noreply, socket}
  end
end
