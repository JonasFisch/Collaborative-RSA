defmodule AlgoThinkWeb.StudyGroupLive.Index do
  use AlgoThinkWeb, :live_view

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classroom")
    |> assign(:classroom, nil)
  end
end
