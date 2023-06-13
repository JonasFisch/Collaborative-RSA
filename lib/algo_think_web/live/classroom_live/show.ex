defmodule AlgoThinkWeb.ClassroomLive.Show do
  use AlgoThinkWeb, :live_view

  alias AlgoThink.Classrooms

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:classroom, Classrooms.get_classroom!(id))}
  end

  defp page_title(:show), do: "Show Classroom"
  defp page_title(:edit), do: "Edit Classroom"
end
