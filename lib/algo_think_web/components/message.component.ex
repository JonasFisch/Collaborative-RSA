defmodule AlgoThinkWeb.Message do
  use Phoenix.Component

  attr :text, :string, required: false, doc: "Text of the message."
  attr :author, :string, required: true, doc: "Author of the message."
  attr :time, :string, required: false, doc: "Time the message was send."
  attr :self, :boolean, default: false, doc: "changes color and position of message indicates who is author."
  def message(assigns) do
    ~H"""
    <div class={[
      "rounded-md py-1 px-2 flex flex-col border-2",
      if @self do "bg-blue-500 border-blue-500" else "bg-white" end
    ]}>
      <%= if not @self do %>
        <span class="font-bold">
          <%= @author %>
        </span>
      <% end %>
      <span class={[
        if @self do "text-white" else "text-black" end
      ]}>
        <%= @text %>
      </span>
      <span class={[
        "text-sm self-end",
        if @self do "text-white" else "text-gray-400" end
      ]}>
        <%= @time %>
      </span>
    </div>
    """
  end
end
