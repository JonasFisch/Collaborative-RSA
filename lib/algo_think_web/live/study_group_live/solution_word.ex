defmodule AlgoThinkWeb.StudyGroupLive.SolutionWord do
  alias AlgoThink.StudyGroups
  alias AlgoThink.CryptoModuleValidation
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full" phx-hook="drag" id="solution-module">
      <div class="flex justify-between items-center">
        <%= for user <- @users do %>
          <% crytpo_artifact = Enum.find(@crypto_artifacts, fn artifact -> artifact.location_id == "result_#{user.id}" end) %>
          <div class="w-1/4 text-center">
            <span class="flex flex-row justify-center gap-2 items-center mb-1 font-medium">
              <%= user.name %>
              <div class="bg-green-300 rounded-full p-1" :if={crytpo_artifact != nil && Map.get(@errors, "result_#{user.id}") == nil}>
                <MaterialIcons.check class="fill-black" size={18} />
              </div>
            </span>
            <.drop_zone
              small={true}
              placeholder="Drop Message"
              error={Map.get(@errors, "result_#{user.id}")}
              class={[
                "phx-dragging:!bg-gray-100",
                if crytpo_artifact != nil && Map.get(@errors, "result_#{user.id}") == nil do "!border-green-300" end
              ]}
              id={"result_#{user.id}"}
              crypto_artifact={crytpo_artifact}
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, errors: %{}, users: [])}
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

    users = if (length(socket.assigns.users) == 0) do
      StudyGroups.get_study_group!(assigns.study_group_id) |> Map.get(:users)
    else
      socket.assigns.users
    end

    # check for task done
    if (Enum.all?(Enum.map(users, fn user ->
      crytpo_artifact = Enum.find(assigns.crypto_artifacts, fn artifact -> artifact.location_id == "result_#{user.id}" end)
      crytpo_artifact != nil && Map.get(updated_errors, "result_#{user.id}") == nil
    end))) do
      StudyGroups.set_user_done_task(assigns.current_user.id, assigns.study_group_id)
      send(self(), %{topic: "task_done"})
    end

    {:ok, socket
      |> assign(assigns)
      |> assign(errors: updated_errors)
      |> assign(users: users)
    }
  end

  @impl true
  def handle_event("dropped", params, socket) do
    drop_zone_id = params["dropzoneId"]
    crypto_artifact_id = Map.get(params, "draggedId")
    crypto_artifact = CryptoArtifacts.get_crypto_artifact!(crypto_artifact_id)

    send(self(), %{topic: "update_chip_location", dragged_id: crypto_artifact_id, drop_zone_id: drop_zone_id, location: "solution_word"})

    artifact_owner_id = String.replace(drop_zone_id, "result_", "")

    changeset = CryptoModuleValidation.changeset_solution(Map.from_struct(crypto_artifact), artifact_owner_id)

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
