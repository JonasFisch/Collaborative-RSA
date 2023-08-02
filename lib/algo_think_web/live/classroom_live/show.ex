defmodule AlgoThinkWeb.ClassroomLive.Show do
  alias AlgoThink.StudyGroups
  use AlgoThinkWeb, :live_view

  alias AlgoThink.Classrooms

  @topic "classroom"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    AlgoThinkWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, classroom_id: id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    AlgoThinkWeb.Endpoint.subscribe("classroom:#{id}")

    classroom = Classrooms.get_classroom!(id)
    user_no_study_group = Classrooms.students_with_no_study_group(classroom.id)

    classroom = Map.put(classroom, :study_groups, Enum.map(classroom.study_groups, fn study_group ->
      StudyGroups.add_task_finished_state(study_group)
    end))

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:classroom, classroom)
     |> assign(:user_no_study_group, user_no_study_group)
    }
  end

  @impl true
  def handle_info(%{topic: @topic, event: event, payload: _classroom}, socket) do
    case event do
      "classroom_updated" ->
        classroom = Classrooms.get_classroom!(socket.assigns.classroom.id)
        user_no_study_group = Classrooms.students_with_no_study_group(classroom.id)

        classroom = Map.put(classroom, :study_groups, Enum.map(classroom.study_groups, fn study_group ->
          StudyGroups.add_task_finished_state(study_group)
        end))

        if (classroom.state == :running && socket.assigns.current_user.role == :student) do
          current_study_group_id = StudyGroups.get_study_group_for_classroom(socket.assigns.current_user, classroom)
          {:noreply, socket
            |> push_navigate(to: "/classroom/#{classroom.id}/studygroup/#{current_study_group_id}")
          }
        else
          {:noreply, socket
            |> assign(:classroom, classroom)
            |> assign(:user_no_study_group, user_no_study_group)
          }
        end

      "classroom_deleted" ->
        {:noreply, socket
        |> put_flash(:warning, "the classroom has been deleted.")
        |> redirect(to: ~p"/classroom")}

      _other ->
        IO.warn("unknown event")
        {:noreply, socket}
    end
  end

  def handle_info({AlgoThinkWeb.ClassroomLive.FormComponent, {:saved, classroom}}, socket) do
    {:noreply, socket |> assign(:classroom, classroom)}
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    IO.inspect("starting the Game")
    {:ok, classroom} = Classrooms.update_classroom(socket.assigns.classroom, %{state: :running})

    for study_group <- classroom.study_groups do
      StudyGroups.update_study_group(study_group, %{state: :key_gen})
    end

    send(self(), %{topic: @topic, event: "classroom_updated", payload: ""})
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_next_task", _params, socket) do
    IO.inspect("starting the next Task")

    # reset task done
    for study_group <- socket.assigns.classroom.study_groups do
      StudyGroups.reset_user_done_task(study_group.id)
    end

    # set study group state
    for study_group <- socket.assigns.classroom.study_groups do
      {:ok, _update_study_group} = StudyGroups.update_study_group(study_group, %{state: :rsa})
      # TODO: send websocket message to all clients that the state has updated

      AlgoThinkWeb.Endpoint.broadcast_from(
        self(),
        "study_group_#{study_group.id}",
        "state_updated",
        study_group
      )
    end

    # update classroom for teacher
    send(self(), %{topic: @topic, event: "classroom_updated", payload: ""})
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Classroom"
  defp page_title(:edit), do: "Edit Classroom"
end
