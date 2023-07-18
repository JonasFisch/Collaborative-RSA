defmodule AlgoThinkWeb.Message do
  alias AlgoThink.CryptoArtifacts
  use Phoenix.Component

  attr :text, :string, required: false, doc: "Text of the message."
  attr :author, :string, required: true, doc: "Author of the message."
  attr :time, :string, required: false, doc: "Time the message was send."
  attr :attachment, CryptoArtifacts.CryptoArtifact, required: false, default: nil, doc: "An attached Crypto Artefact"
  attr :self, :boolean, default: false, doc: "changes color and position of message indicates who is author."
  def message(assigns) do
    ~H"""
    <div class={[
      "rounded-md py-1 px-2 flex flex-col border-2 w-fit min-w-chip",
      if @self do "bg-blue-500 border-blue-500 self-end" else "bg-white self-start" end
    ]}>
      <%= if not @self do %>
        <span class="font-bold">
          <%= @author %>
        </span>
      <% end %>
      <%= if @attachment != nil do %>
        <div class="mb-2">
          <AlgoThinkWeb.Chip.chip type={@attachment.type} name={"test"} signed={@attachment.signed} />
        </div>
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
