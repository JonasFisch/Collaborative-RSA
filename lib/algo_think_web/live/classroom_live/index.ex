defmodule AlgoThinkWeb.ClassroomLive.Index do
  use AlgoThinkWeb, :live_view

  alias AlgoThink.Classrooms
  alias AlgoThink.Classrooms.Classroom

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :classroom_collection, Classrooms.list_classroom_for_owner(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Classroom")
    |> assign(:classroom, Classrooms.get_classroom!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Classroom")
    |> assign(:classroom, %Classroom{})
  end

  defp apply_action(socket, :join, _params) do
    socket
    |> assign(:page_title, "Join Classroom")
    |> assign(:classroom, %Classroom{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classroom")
    |> assign(:classroom, nil)
  end

  @impl true
  def handle_info({AlgoThinkWeb.ClassroomLive.FormComponent, {:saved, classroom}}, socket) do
    {:noreply, stream_insert(socket, :classroom_collection, classroom)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    classroom = Classrooms.get_classroom!(id)
    {:ok, _} = Classrooms.delete_classroom(classroom)

    {:noreply, stream_delete(socket, :classroom_collection, classroom)}
  end

  def handle_event("handle_shortcuts", %{"altKey" => true, "key" => key}, socket) do
    case key do
      "n" -> {:noreply, socket |> redirect(to: ~p"/classroom/new")}
      "j" -> {:noreply, socket |> redirect(to: ~p"/classroom/join")}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("handle_shortcuts", _params, socket) do
    {:noreply, socket}
  end
end
