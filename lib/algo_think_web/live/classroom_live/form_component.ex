defmodule AlgoThinkWeb.ClassroomLive.FormComponent do
  use AlgoThinkWeb, :live_component

  alias AlgoThink.Classrooms.ClassroomToken
  alias AlgoThink.Classrooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Create a new Classroom and use the generated token to invite all students in the class.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="classroom-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name"/>

        <:actions>
          <.button phx-disable-with="Saving...">Save Classroom</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{classroom: classroom} = assigns, socket) do
    changeset = Classrooms.change_classroom(classroom)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"classroom" => classroom_params}, socket) do
    changeset =
      socket.assigns.classroom
      |> Classrooms.change_classroom(classroom_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"classroom" => classroom_params}, socket) do
    save_classroom(socket, socket.assigns.action, classroom_params)
  end

  defp save_classroom(socket, :edit, classroom_params) do
    case Classrooms.update_classroom(socket.assigns.classroom, classroom_params) do
      {:ok, classroom} ->
        notify_parent({:saved, classroom})

        {:noreply,
         socket
         |> put_flash(:info, "Classroom updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_classroom(socket, :new, classroom_params) do
    classroom_params = Map.put(classroom_params, "token", ClassroomToken.generateUniqueToken(5))
    case Classrooms.create_classroom(classroom_params) do
      {:ok, classroom} ->
        notify_parent({:saved, classroom})

        {:noreply,
         socket
         |> put_flash(:info, "Classroom created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
