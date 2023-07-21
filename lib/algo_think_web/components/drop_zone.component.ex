defmodule AlgoThinkWeb.DropZone do
  alias AlgoThink.CryptoArtifacts.CryptoArtifact
  use Phoenix.Component

  @doc """
  Renders a Drop Zone.
  """
  attr :class, :string, default: nil
  attr :error, :string, default: nil, required: false
  attr :placeholder, :string, default: "Drop Something"
  attr :is_result, :boolean, default: false
  attr :crypto_artifact, CryptoArtifact, required: false, default: nil
  attr :rest, :global, include: ~w(phx-click phx-target), doc: "the arbitrary HTML attributes to add to the drop zone"
  attr :id, :string, required: true

  slot :inner_block, required: false

  def drop_zone(assigns) do
    ~H"""
    <div id={@id} class={[
      "rounded-md border-2 border-dashed border-gray-300 flex flex-row justify-center w-full items-center transition-colors",
      if @crypto_artifact != nil do "cursor-pointer" end,
      if @is_result do "border-gray-300 bg-gray-300" else "drop-zone" end,
      if @error != nil do
        if @is_result do "border-red-400 bg-red-400" else "border-red-400" end
      end,
      @class
    ]}>
      <%= if @crypto_artifact != nil do %>
        <div {@rest} class="w-full p-1" phx-value-crypto-artifact-id={@crypto_artifact.id} phx-value-crypto-artifact-type={@crypto_artifact.type}>
          <AlgoThinkWeb.Chip.chip id={@crypto_artifact.id} name={@crypto_artifact.owner.name} type={@crypto_artifact.type} />
        </div>
      <% else %>
        <div class="w-full p-1 relative">
          <AlgoThinkWeb.Chip.chip id={"placeholder-crypto-module-#{@id}"} name={"nil"} type={:message} class="invisible" />
          <span class={[
            "text-gray-400 font-medium absolute bottom-0 left-0 flex flex-row justify-center items-center w-full h-full",
            if @error != nil do
              if @is_result do "text-white" else "text-red-400" end
            end,
          ]}>
            <%= if @error == :nil do @placeholder else @error end %>
          </span>
        </div>
      <% end %>
    </div>
    """
  end
end
