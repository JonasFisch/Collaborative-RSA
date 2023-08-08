defmodule AlgoThinkWeb.TaskCompletedModal do
  use Phoenix.Component

  attr :visible, :boolean, default: false
  attr :on_ok_clicked, :string

  def task_completed_modal(assigns) do
    ~H"""
    <div>
      <%!-- backdrop --%>
      <div class={[
        "left-0 top-0 transition-opacity pointer-events-none inset-0 fixed h-screen w-screen opacity-0 bg-gray-400 z-50",
        if @visible do "opacity-70 !pointer-events-auto" end
      ]}
      ></div>

      <%!-- hover info --%>
      <div class={[
        "pointer-events-none left-0 top-0 absolute h-full opacity-0 w-full z-50",
        if @visible do "!pointer-events-auto opacity-100 animate-jump-in" end
      ]}>
        <div class="flex justify-center items-center w-full h-full">
          <div class="max-w-3/10 bg-white rounded-md p-6 flex flex-col justify-center items-center gap-2">
            <MaterialIcons.check_circle style="round" class="fill-green-400" size={50} />
            <span class="font-bold text-xl">Task Done</span>
            <span class="text-sm text-gray-400 font-bold max-w-8/10 text-center">Waiting for others to complete Task. You may also need to help others to complete their task.</span>
            <AlgoThinkWeb.Button.button phx-click={@on_ok_clicked} class="w-20">OK</AlgoThinkWeb.Button.button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
