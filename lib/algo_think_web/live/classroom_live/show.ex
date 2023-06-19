defmodule AlgoThinkWeb.ClassroomLive.Show do
  use AlgoThinkWeb, :live_view

  alias AlgoThink.Classrooms

  @topic "classroom"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    IO.inspect(id)
    AlgoThinkWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, classroom_id: id)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    AlgoThinkWeb.Endpoint.subscribe("classroom:#{id}")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:classroom, Classrooms.get_classroom!(id))}
  end

  @impl true
  def handle_info(%{topic: @topic, event: event, payload: _msg}, socket) do
    case event do
      "classroom_updated" ->
        {:noreply, socket |> assign(:classroom, Classrooms.get_classroom!(socket.assigns.classroom_id))}

      "classroom_deleted" ->
        {:noreply, socket
        |> put_flash(:warning, "the classroom has been deleted.")
        |> redirect(to: ~p"/classroom")}
      _other ->
        IO.warn("unknown event")
        {:noreply, socket}
    end

  end

  defp page_title(:show), do: "Show Classroom"
  defp page_title(:edit), do: "Edit Classroom"
end
