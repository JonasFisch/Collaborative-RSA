defmodule AlgoThinkWeb.Chip do
  use Phoenix.Component

  attr :name, :string, required: true, doc: "Name of the chip creator"
  attr :signed, :boolean, default: false, required: false, doc: "chip is signed"
  attr :class, :string, default: nil

  attr :type, :atom,
    values: [:public_key, :private_key, :encrypted_message, :message, :signature],
    required: true,
    doc: "type defines an appeareance for the chip"

  def chip(assigns) do
    ~H"""
    <div class={[
      "bg-white border border-slate-200 flex flex-row items-center w-full p-3 justify-between h-chip",
      @class
    ]}>
      <MaterialIcons.drag_indicator class="fill-gray-300 mr-2" size={32} />
      <span class="font-bold text-left w-1/3"><%= @name %></span>
      <span class="text-gray-500 w-1/3 text-sm text-left">
        <%= case @type do %>
          <% :public_key -> %>
            Public Key
          <% :private_key -> %>
            Private Key
          <% :encrypted_message -> %>
            Encrypted Message
          <% :message -> %>
            Message
          <% :signature -> %>
            Signature
        <% end %>
      </span>
      <div class={[
        "rounded-full w-9 h-9 flex justify-center items-center relative ml-6",
        case @type do
          :public_key -> "bg-green-400"
          :private_key -> "bg-green-400"
          :encrypted_message -> "bg-red-400"
          :message -> "bg-blue-400"
          :signature -> "bg-yellow-400"
        end
      ]}>
        <%!-- <%= IO.inspect(@type) %> --%>
        <%= case @type do %>
          <% :public_key -> %>
            <MaterialIcons.vpn_key style="outlined" class="fill-black" size={25} />
          <% :private_key -> %>
            <MaterialIcons.vpn_key style="outlined" class="fill-black" size={25} />
          <% :encrypted_message -> %>
            <MaterialIcons.lock style="outlined" class="fill-black" size={25} />
          <% :message -> %>
            <MaterialIcons.mail style="outlined" class="fill-black" size={25} />
          <% :signature -> %>
            <MaterialIcons.tag style="outlined" class="fill-black" size={25} />
        <% end %>
        <div
          :if={@signed}
          class="absolute -left-4 rounded-full w-5 h-5 flex justify-center items-center bg-yellow-300"
        >
          <MaterialIcons.check class="fill-black" size={16} />
        </div>
      </div>
    </div>
    """
  end
end
