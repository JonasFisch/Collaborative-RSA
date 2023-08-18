defmodule AlgoThinkWeb.Accordion do
  use Phoenix.Component

  attr :header, :string, required: true
  attr :open, :boolean, default: false
  attr :rest, :global

  slot :inner_block, required: false


  @spec accordion(map) :: Phoenix.LiveView.Rendered.t()
  def accordion(assigns) do
    ~H"""
    <details class="bg-gray-100 rounded-md p-3 group mx-6 select-none" open={@open} >
      <summary class="list-none cursor-pointer" {@rest}>
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
