defmodule AlgoThinkWeb.Container do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :title, :string, default: " "
  attr :always_show_title, :boolean, default: false

  attr :rest, :global

  slot :inner_block, required: true


  def container(assigns) do
    ~H"""
    <div class={[
      "rounded-xl border-2 py-4 px-2 bg-white h-full",
      @class
    ]} {@rest}>
      <div class="drop-zone h-full w-full">
        <h2 class={[
          "absolute text-lg font-bold text-center -top-4 left-1/2 -translate-x-1/2 bg-white px-4 text-gray-400 transition-opacity opacity-100",
          if not @always_show_title do "phx-dragging:opacity-0" end
        ]}
        ><%= @title %></h2>
        <div class="h-full overflow-hidden rounded-xl w-full">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
