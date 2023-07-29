defmodule AlgoThinkWeb.Container do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :title, :string, default: " "

  attr :rest, :global

  slot :inner_block, required: true


  def container(assigns) do
    ~H"""
    <div class={[
      "rounded-xl border-2 shadow-default p-4 bg-white h-full overflow-hidden",
      @class
    ]} {@rest}>
      <h2 class="text-lg font-bold text-center"><%= @title %></h2>
      <div class="h-full">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
