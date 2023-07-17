defmodule AlgoThinkWeb.DropZone do
  alias AlgoThink.CryptoArtifacts.CryptoArtifact
  use Phoenix.Component

  @doc """
  Renders a Drop Zone.
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :error, :string, default: nil, required: false
  attr :placeholder, :string, default: "Drop Something"
  attr :crypto_artifact, CryptoArtifact, required: false, default: nil

  slot :inner_block, required: false

  def drop_zone(assigns) do
    ~H"""
    <div class={[
      "rounded-md border-2 border-dashed border-gray-300 p-4 flex flex-row justify-center",
      if @crypto_artifact != nil do "p-1 border-none" end,
      if @error != nil do "border-red-400" end,
      @class
    ]}>
      <%= if @crypto_artifact != nil do %>
        <AlgoThinkWeb.Chip.chip name={@crypto_artifact.owner_id} type={@crypto_artifact.type}/>
      <% else %>
        <span class={[
          "text-gray-400 font-medium",
          if @error != nil do "text-red-400" end,
        ]}>
          <%= if @error == :nil do @placeholder else @error end %>
        </span>
      <% end %>

    </div>
    """
  end
end
