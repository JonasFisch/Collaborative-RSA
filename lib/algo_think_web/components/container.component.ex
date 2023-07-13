defmodule AlgoThinkWeb.Container do
  use Phoenix.Component

  slot :inner_block, required: true
  def container(assigns) do
    ~H"""
    <div class="rounded-xl border-2 shadow-default h-3/5 p-2">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
