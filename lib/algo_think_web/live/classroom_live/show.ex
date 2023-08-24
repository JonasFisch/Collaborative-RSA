defmodule AlgoThinkWeb.ClassroomLive.Show do
  use AlgoThinkWeb, :live_view
  alias AlgoThink.PerformanceLogs
  alias AlgoThink.ChatMessages
  alias AlgoThink.CryptoArtifacts
  alias AlgoThink.ChipStorage
  alias AlgoThink.StudyGroups

  alias AlgoThink.Classrooms

  @topic "classroom"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    AlgoThinkWeb.Endpoint.subscribe(@topic)

    IO.inspect(Faker.Pokemon.name())

    {:ok, assign(socket, classroom_id: id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    AlgoThinkWeb.Endpoint.subscribe("classroom:#{id}")

    classroom = Classrooms.get_classroom!(id)
    user_no_study_group = Classrooms.students_with_no_study_group(classroom.id)

    # add finished state to each study group
    classroom = Map.put(classroom, :study_groups, Enum.map(classroom.study_groups, fn study_group ->
      StudyGroups.add_task_finished_state(study_group)
    end))

    # determine is all students are finished
    all_finished = Enum.reduce(classroom.study_groups, true, fn study_group, acc ->
      acc && study_group.task_finished == length(study_group.users)
    end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:classroom, classroom)
     |> assign(:user_no_study_group, user_no_study_group)
     |> assign(:all_finished, all_finished)
    }
  end

  @impl true
  def handle_info(%{topic: @topic, event: event, payload: _classroom}, socket) do
    case event do
      "classroom_updated" ->
        classroom = Classrooms.get_classroom!(socket.assigns.classroom.id)
        user_no_study_group = Classrooms.students_with_no_study_group(classroom.id)

        # add task finished state
        classroom = Map.put(classroom, :study_groups, Enum.map(classroom.study_groups, fn study_group ->
          StudyGroups.add_task_finished_state(study_group)
        end))

        # determine is all students are finished
        all_finished = Enum.reduce(classroom.study_groups, true, fn study_group, acc ->
          acc && study_group.task_finished == length(study_group.users)
        end)

        if (classroom.state == :key_gen && socket.assigns.current_user.role == :student) do
          current_study_group_id = StudyGroups.get_study_group_for_classroom(socket.assigns.current_user, classroom)
          {:noreply, socket
            |> push_navigate(to: "/classroom/#{classroom.id}/studygroup/#{current_study_group_id}")
          }
        else
          {:noreply, socket
            |> assign(:classroom, classroom)
            |> assign(:user_no_study_group, user_no_study_group)
            |> assign(:all_finished, all_finished)
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
    {:ok, classroom} = Classrooms.update_classroom(socket.assigns.classroom, %{state: :key_gen})

    # log that user starts task now
    for user <- socket.assigns.classroom.users do
      PerformanceLogs.log_user_started_task(user.id, :key_gen)
    end

    send(self(), %{topic: @topic, event: "classroom_updated", payload: classroom})
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_next_task", _params, socket) do
    IO.inspect("starting the next Task")

    # reset task done
    for study_group <- socket.assigns.classroom.study_groups do
      StudyGroups.reset_user_done_task(study_group.id)
      StudyGroups.reset_error_count(study_group.id)
      ChatMessages.clear_chat_history(study_group)


      for user <- study_group.users do
        # delete all crypto artifacts except the users key pair
        CryptoArtifacts.delete_crypto_artifacts_for_user(user, study_group)

        # create message for each user
        {:ok, message} = AlgoThink.CryptoArtifacts.create_message(user.id, "Random Message")
        ChipStorage.create_crypto_artifact_user(%{user_id: user.id, study_group_id: study_group.id, crypto_artifact_id: message.id })
      end
    end

    # get next phase of the game
    next_state = case socket.assigns.classroom.state do
      :key_gen -> :rsa
      :rsa -> :rsa_with_signatures
      :rsa_with_signatures -> :finished
      _ -> IO.warn("invalid next state given!")
    end

    for user <- socket.assigns.classroom.users do
      PerformanceLogs.log_user_started_task(user.id, next_state)
    end

    {:ok, classroom} = Classrooms.update_classroom(socket.assigns.classroom, %{state: next_state})

    AlgoThinkWeb.Endpoint.broadcast_from(
      self(),
      "classroom",
      "state_update",
      classroom
    )

    # update classroom for teacher
    send(self(), %{topic: @topic, event: "classroom_updated", payload: ""})
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Classroom"
  defp page_title(:edit), do: "Edit Classroom"
end
