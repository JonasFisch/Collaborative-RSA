defmodule AlgoThinkWeb.StudyGroupLive.CryptoModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.accordion header="Encryption">
        <div class="flex flex-col gap-4">
          <%= for slot <- @data do %>
            <div class="flex flex-row justify-between items-center gap-4">
              <span class="w-2/6 font-medium">
                <%= slot.name %>:
              </span>
              <.drop_zone placeholder={"#{slot.placeholder}"} is_result={slot.result} />
            </div>
          <% end %>
        </div>
      </.accordion>
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
  def mount(socket) do
    {:ok, socket |> assign(data: [
      %{name: "Plain Message", placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
      %{name: "Encrypt with", placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
      %{name: "Encrypted Message", placeholder: "Result", expected_type: :message, encrypted: true, result: true},
    ])}
  end
end
