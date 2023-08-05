defmodule AlgoThinkWeb.StudyGroupLive.SolutionWord do
  alias AlgoThink.CryptoModuleValidation
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full mt-4" phx-hook="drag" id="solution-module">
      <div class="flex justify-between items-center">
        <%= for number <- 0..3 do %>
          <div class="w-1/5">
            <.drop_zone small={true} error={Map.get(@errors, "result_#{number}")} class="phx-dragging:bg-gray-100" id={"result_#{number}"} crypto_artifact={Enum.find(@crypto_artifacts, fn artifact -> artifact.location_id == "result_#{number}" end)}></.drop_zone>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, errors: %{})}
  end

  @impl true
  def update(assigns, socket) do
    # update error messages
    updated_errors = Enum.reduce(socket.assigns.errors, %{}, fn {key, error_msg}, acc ->
      found = nil != Enum.find(assigns.crypto_artifacts, fn crypto_artifact -> crypto_artifact.location_id == key end)
      if (not found) do
        # if no crypto artifact is on that location, remove error message
        Map.put(acc, key, nil)
      else
        Map.put(acc, key, error_msg)
      end
    end)

    {:ok, socket
      |> assign(assigns)
      |> assign(errors: updated_errors)
    }
  end

  @impl true
  def handle_event("dropped", params, socket) do
    crypto_artifact_id = Map.get(params, "draggedId")
    crypto_artifact = CryptoArtifacts.get_crypto_artifact!(crypto_artifact_id)

    send(self(), %{topic: "update_chip_location", dragged_id: crypto_artifact_id, drop_zone_id: params["dropzoneId"], location: "solution_word"})

    changeset = CryptoModuleValidation.changeset_solution(Map.from_struct(crypto_artifact))

    if (length(changeset.errors) > 0) do
      # extract error message from changeset
      errors = changeset.errors
      |> Enum.reduce([], fn error, acc ->
        {_key, {msg, _other}} = error
        acc ++ [msg]
      end)

      updated_errors = socket.assigns.errors |> Map.put(params["dropzoneId"], Enum.at(errors, 0))
      {:noreply, socket |> assign(errors: updated_errors)}
    else
      {:noreply, socket}
    end
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
