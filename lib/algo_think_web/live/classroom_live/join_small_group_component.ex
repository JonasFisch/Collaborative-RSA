defmodule AlgoThinkWeb.ClassroomLive.JoinSmallGroupComponent do
  alias AlgoThink.Classrooms
  alias AlgoThink.StudyGroups
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-7">
      <table class="w-full">

        <tr>
          <th class="text-left"></th>
          <th class="text-left pb-5">Participants</th>
          <th class="text-center pb-5">Task Progress</th>
          <th class="text-right"></th>
        </tr>

        <%!-- study groups --%>
        <tr :for={study_group <- @classroom.study_groups} class="text-sm leading-6 sm:gap-8 relative mt-6" :if={@classroom.state == :group_finding || length(study_group.users) > 0}>
          <th class="h-8 text-zinc-500 align-top text-left flex flex-row items-center">
            <p class="font-medium whitespace-nowrap">
              <%= study_group.name %>
            </p>
            <div :if={not @is_teacher}>
              <%= if @current_study_group_id == study_group.id do %>
                <button phx-value-id={study_group.id} class="bg-green-500 transition-colors text-white px-3 rounded-xl ml-3 h-6">
                  <.icon name="hero-check-mini" class="h-4 w-4 table my-auto" />
                </button>
              <% else %>
                <button phx-value-id={study_group.id} phx-click="join_study_group" phx-target={@myself} class="bg-blue-500 hover:bg-blue-600 transition-colors text-white px-3 rounded-xl ml-3">
                  join
                </button>
              <% end %>
            </div>
          </th>
          <th class="text-zinc-700 h-24 ml-12 align-top text-left">
            <p :for={user <- Enum.sort_by(study_group.users, fn user -> user.name end)} class="animate-fade-in">
              <%= user.name %>
            </p>
          </th>
          <th class="align-top text-center">
            <div :if={length(study_group.users) > 0} class={[
              if length(study_group.users) > 0 && study_group.task_finished == length(study_group.users) do "bg-green-300" else "bg-red-300" end,
              "rounded-xl w-56 m-auto"
            ]}>
              <p class="ml-3 mr-0 flex flex-row justify-center gap-1 items-center">
                <span>
                  <%= if length(study_group.users) > 0 && study_group.task_finished == length(study_group.users) do "Done" else "In Progress ..." end %>
                </span>
                <MaterialIcons.check :if={length(study_group.users) > 0 && study_group.task_finished == length(study_group.users)} class="fill-gray-700" size={20} />
              </p>
            </div>
          </th>
          <th class="align-top text-right">
            <div>
              <p>
                <%=
                if @classroom.state == :group_finding do
                  "#{length(study_group.users)} / #{study_group.max_users}"
                else
                  "#{study_group.task_finished} / #{length(study_group.users)}"
                end
                %>
              </p>
            </div>
          </th>
        </tr>

        <%!-- not joined yet list --%>
        <tr class="gap-4 text-sm leading-6 sm:gap-8">
          <th class="h-8 text-zinc-500 align-top text-left flex flex-row items-center">
            <p class="font-medium whitespace-nowrap">
              No group
            </p>
            <%= if @current_study_group_id != nil && not @is_teacher do %>
              <button phx-value-id={nil} phx-click="join_no_group" phx-target={@myself} class="bg-blue-500 hover:bg-blue-600 transition-colors text-white px-3 rounded-xl ml-3">
                join
              </button>
            <% end %>
          </th>
          <th class="text-zinc-700 h-24 overflow-y-auto ml-12 text-left align-top">
            <p :for={user <- Enum.sort_by(@user_no_study_group, fn user -> user.name end)} class="animate-fade-in">
              <%= user.name %>
            </p>
          </th>
          <th></th>
          <th></th>
        </tr>
      </table>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    current_user = assigns.current_user
    classroom = assigns.classroom
    current_study_group_id = StudyGroups.get_study_group_for_classroom(current_user, classroom)
    user_no_study_group = Classrooms.students_with_no_study_group(classroom.id)
    is_teacher = current_user.role == :teacher

    {:ok,
      socket
      |> assign(assigns)
      |> assign(
        user_no_study_group: user_no_study_group,
        current_study_group_id: current_study_group_id,
        is_teacher: is_teacher
      )
    }
  end

  @impl true
  def handle_event("join_study_group", params, socket) do

    classroom = socket.assigns.classroom
    current_user = socket.assigns.current_user
    study_group_id = params["id"]

    with {:ok, _result} <- StudyGroups.join_study_group(classroom, current_user, study_group_id) do
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

  @impl true
  def handle_event("join_no_group", _params, socket) do
    classroom = socket.assigns.classroom
    current_user = socket.assigns.current_user

    with {:ok, _result} <- StudyGroups.join_no_group(classroom, current_user) do
      send(
        self(),
        %{topic: "classroom", event: "classroom_updated", payload: nil}
      )
      {:noreply, socket}
    else
      {:error, msg} ->
        IO.inspect("ERROR")

        {:noreply, socket |> put_flash!(:warning, msg)}
    end

  end
end
