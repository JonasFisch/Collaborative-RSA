defmodule AlgoThinkWeb.Accordion do
  use Phoenix.Component

  attr :header, :string, required: true
  attr :open, :boolean, default: false

  slot :inner_block, required: false
  def accordion(assigns) do
    ~H"""
    <details class="bg-gray-100 rounded-md p-3 group m-6" open={@open}>
      <summary class="list-none cursor-pointer">
        <div class="flex justify-between items-center">
          <span class="font-medium text-xl"><%= @header %></span>
          <MaterialIcons.chevron_right class="fill-gray-400 group-open:rotate-90 transition-transform" size={32} />
        </div>
      </summary>
      <div class="mt-3 w-full">
        <%= render_slot(@inner_block) %>
      </div>
    </details>
    """
  end
end
