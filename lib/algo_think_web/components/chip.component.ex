defmodule AlgoThinkWeb.Chip do
  use Phoenix.Component

  attr :name, :string, required: true, doc: "Name of the chip creator"
  attr :valid, :boolean, default: false, required: false, doc: "chip is valid"
  attr :class, :string, default: nil
  attr :id, :string, required: true
  attr :encrypted, :boolean, default: false

  attr :type, :atom,
    values: [:public_key, :private_key, :message, :signature],
    required: true,
    doc: "type defines an appeareance for the chip"

  def chip(assigns) do
    ~H"""
    <div draggable="true" id={"crypto-artifact-#{@id}"} phx-hook="draggable" class={[
      "draggable bg-white border border-slate-200 flex flex-row items-center w-full p-3 justify-between h-chip",
      @class
    ]}
    >
      <MaterialIcons.drag_indicator class="fill-gray-300 mr-2" size={32} />
      <span class="font-bold text-left w-1/3"><%= @name %></span>
      <span class="text-gray-500 w-1/3 text-sm text-left">

        <%= case @type do
          :public_key -> "Public Key"
          :private_key -> "Private"
          :message -> if @encrypted do "Encrypted Message" else "Message" end
          :signature -> "Signature"
          _ -> "unknown"
        end %>
      </span>
      <div class={[
        "rounded-full w-9 h-9 flex justify-center items-center relative ml-6",
        case @type do
          :public_key -> "bg-green-400"
          :private_key -> "bg-green-400"
          :message -> if @encrypted do "bg-red-400" else "bg-blue-400" end
          :signature -> "bg-yellow-400"
        end
      ]}>
        <%!-- <%= IO.inspect(@type) %> --%>
        <%= case @type do %>
          <% :public_key -> %>
            <MaterialIcons.vpn_key style="outlined" class="fill-black" size={25} />
          <% :private_key -> %>
            <MaterialIcons.vpn_key style="outlined" class="fill-black" size={25} />
          <% :message -> %>
            <%= if @encrypted do %>
              <MaterialIcons.lock style="outlined" class="fill-black" size={25} />
            <% else %>
              <MaterialIcons.mail style="outlined" class="fill-black" size={25} />
            <% end %>
          <% :signature -> %>
            <MaterialIcons.tag style="outlined" class="fill-black" size={25} />
        <% end %>
        <div
          class="absolute -left-4 "
        >
          <div :if={@valid == :valid} class="rounded-full w-5 h-5 flex justify-center items-center bg-yellow-300">
            <MaterialIcons.check class="fill-black" size={16} />
          </div>
          <div :if={@valid == :invalid} class="rounded-full w-5 h-5 flex justify-center items-center bg-red-300">
            <MaterialIcons.close class="fill-black" size={16} />
          </div>
        </div>
      </div>
    </div>
    """
  end
end
