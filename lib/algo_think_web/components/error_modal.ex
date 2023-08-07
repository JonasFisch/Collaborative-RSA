defmodule AlgoThinkWeb.ErrorModal do
  use Phoenix.Component

  attr :primary_text, :string
  attr :secondary_text, :string
  attr :visible, :boolean, default: false

  def error_modal(assigns) do
    ~H"""
    <div>
      <%!-- backdrop --%>
      <div class={[
        "rounded-xl transition-opacity pointer-events-none absolute left-0 top-0 h-full w-full opacity-0 phx-dragging:block bg-gray-700 z-40 backdrop-blur-sm",
        if @visible do "opacity-70 !pointer-events-auto" end
      ]}
      ></div>

      <%!-- hover info --%>
      <div class={[
        "pointer-events-none left-0 top-0 absolute h-full opacity-0 w-full z-50",
        if @visible do "!pointer-events-auto opacity-100 animate-shake" end
      ]}>
        <div class="flex justify-center items-center w-full h-full">
          <div class="max-w-8/10 bg-white rounded-md p-6 flex flex-col justify-center items-center gap-2">
            <MaterialIcons.warning_amber style="round" class="fill-red-400" size={50} />
            <span class="font-bold text-xl"><%= @primary_text %></span>
            <span class="text-sm text-gray-400 font-bold max-w-8/10 text-center"><%= @secondary_text %></span>
            <AlgoThinkWeb.Button.button phx-click="error_modal_ok_pressed" class="w-28 mt-2" color="red">OK</AlgoThinkWeb.Button.button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
