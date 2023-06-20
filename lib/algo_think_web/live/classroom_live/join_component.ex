defmodule AlgoThinkWeb.ClassroomLive.JoinComponent do
  use AlgoThinkWeb, :live_component

  alias AlgoThink.Classrooms
  alias AlgoThink.Classrooms.ClassroomUser

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <p>
          Enter the Token to join a classroom.
        </p>
        <%!-- <:subtitle></:subtitle> --%>
      </.header>


      <form action="post" phx-submit="save" phx-target={@myself} phx-change="validate">
        <div class="mb-4 mt-4">
          <.label for="token">Token</.label>
          <input
            class={[
              "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
              "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
              "border-zinc-300 focus:border-zinc-400",
            ]}
            type="text"
            name="token"
            id="token"
          >
          <.error :for={msg <- @errors}><%= msg %></.error>
        </div>
        <.button phx-disable-with="Joining...">
          Join
        </.button>
      </form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
      |> assign(assigns)
      |> assign(:errors, [])
    }
  end

  @impl true
  def handle_event("save", %{"token" => token}, socket) do
    join_classroom(socket, token)
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket
      |> assign(:errors, [])
    }
  end

  defp join_classroom(socket, token) do
    case Classrooms.classroom_join_by_token(socket.assigns.current_user, token) do
      {:ok, %ClassroomUser{} = classroom_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Successfully joined classroom")
         |> push_navigate(to: ~p"/classroom/#{classroom_user.classroom_id}")
        }

      {:error, msg} ->
        {:noreply, socket |> assign(errors: [msg])} # |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end
end
