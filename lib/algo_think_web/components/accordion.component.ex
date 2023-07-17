defmodule AlgoThinkWeb.Accordion do
  use Phoenix.Component

  attr :header, :string, required: true

  slot :inner_block, required: false
  def accordion(assigns) do
    ~H"""
    <details class="w-full bg-gray-100 rounded-md p-3 group" open>
      <summary class="list-none cursor-pointer mb-3">
        <div class="flex justify-between items-center">
          <span class="font-medium text-xl"><%= @header %></span>
          <MaterialIcons.chevron_right class="fill-gray-400 group-open:rotate-90 transition-transform" size={32} />
        </div>
      </summary>
      <div class="w-full">
        <%= render_slot(@inner_block) %>
      </div>
    </details>
    """
  end
end
