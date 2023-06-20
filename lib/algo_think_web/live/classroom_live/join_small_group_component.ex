defmodule AlgoThinkWeb.ClassroomLive.JoinSmallGroupComponent do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @items} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8 relative">
          <div class="absolute top-4 right-4">
            <p>2/4</p>
          </div>
          <dt class="w-1/4 flex flex-row h-6 text-zinc-500">
            <p class="font-medium">
              <%= item.name %>
            </p>
            <button class="bg-blue-500 hover:bg-blue-600 transition-colors text-white px-3 rounded-xl ml-3">
              join
            </button>
          </dt>
          <dd class="text-zinc-700">Hallo<br>Moin<br></dd>
        </div>
      </dl>

    </div>
    """
  end
end
