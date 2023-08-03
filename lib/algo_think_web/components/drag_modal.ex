defmodule AlgoThinkWeb.DragModal do
  use Phoenix.Component

  attr :primary_text, :string
  attr :secondary_text, :string
  def drag_modal(assigns) do
    ~H"""
    <div>
      <%!-- backdrop --%>
      <div class="rounded-xl pointer-events-none opacity-0 transition-opacity absolute left-0 top-0 h-full w-full phx-dragging:opacity-70 phx-dragging:block bg-gray-700 z-40 backdrop-blur-sm"></div>

      <%!-- hover info --%>
      <div class="scale-90 phx-dragging:scale-100 transition-transform pointer-events-none opacity-0 left-0 top-0 absolute h-full phx-dragging:opacity-100 w-full z-50">
        <div class="flex justify-center items-center w-full h-full">
          <div class="bg-white rounded-md p-4">
            <div class="border-2 border-dashed rounded-md border-gray-800 p-4 flex flex-col items-center">
              <span class="font-bold text-lg"><%= @primary_text %></span>
              <span class="text-sm mt-2"><%= @secondary_text %></span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
