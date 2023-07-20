defmodule AlgoThinkWeb.CrypoModule do
  use Phoenix.Component

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :name, :string, required: true
  attr :fields, :list, default: []

  def crypto_module(assigns) do
    ~H"""
    <div>
      <AlgoThinkWeb.Accordion.accordion header={@name}>
        <div class="flex flex-col gap-4">
          <%= for field <- @fields do %>
            <div class="flex flex-row justify-between items-center gap-4">
              <span class="w-2/6 font-medium">
                <%= field.name %>:
              </span>
              <%IO.inspect(field.crypto_artifact) %>
              <AlgoThinkWeb.DropZone.drop_zone placeholder={"#{field.placeholder}"} is_result={field.result} crypto_artifact={field.crypto_artifact} />
            </div>
          <% end %>
        </div>
      </AlgoThinkWeb.Accordion.accordion>
    </div>
    """
  end
end
