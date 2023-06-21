defmodule AlgoThinkWeb.ClassroomLive.JoinSmallGroupComponent do
  alias AlgoThink.StudyGroups
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={study_group <- @classroom.study_groups} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8 relative">
          <div class="absolute top-4 right-4">
            <p><%= length(study_group.users) %>/<%= study_group.max_users %></p>
          </div>
          <dt class="w-1/4 flex flex-row h-6 text-zinc-500">
            <p class="font-medium">
              <%= study_group.name %>
            </p>
            <%= if @current_study_group_id == study_group.id do %>
              <button phx-value-id={study_group.id} class="bg-green-500 transition-colors text-white px-3 rounded-xl ml-3 flex justify-center items-center">
                <.icon name="hero-check-mini" class="h-4 w-4" />
              </button>
            <% else %>
              <button phx-value-id={study_group.id} phx-click="join_study_group" phx-target={@myself} class="bg-blue-500 hover:bg-blue-600 transition-colors text-white px-3 rounded-xl ml-3">
                join
              </button>
            <% end %>
          </dt>
          <dd class="text-zinc-700 h-24">
            <p :for={user <- study_group.users} class="animate-fade-in">
              <%= user.name %>
            </p>
          </dd>
        </div>
      </dl>

    </div>
    """
  end

  def update(assigns, socket) do
    current_user = assigns.current_user
    classroom = assigns.classroom
    study_groups = classroom.study_groups
    IO.inspect("in update")
    current_study_group_id = StudyGroups.get_study_group_for_classroom(current_user, classroom)

    {:ok,
      socket
      |> assign(current_study_group_id: current_study_group_id)
      |> assign(assigns)
    }
  end

  def handle_event("join_study_group", params, socket) do

    classroom = socket.assigns.classroom
    current_user = socket.assigns.current_user
    study_group_id = params["id"]

    with {:ok, result} <- StudyGroups.join_study_group(classroom, current_user, study_group_id) do
      send(
        self(),
        %{topic: "classroom", event: "classroom_updated", payload: nil}
      )
      {:noreply, socket}
    else
      {:error, msg} ->
        {:noreply, socket |> put_flash!(:warning, msg)}
    end
  end
end
