defmodule AlgoThinkWeb.Container do
  use Phoenix.Component

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true


  def container(assigns) do
    ~H"""
    <div class={[
      "rounded-xl border-2 shadow-default p-2 bg-white max-h-128 overflow-hidden",
      @class
    ]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
