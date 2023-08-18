defmodule AlgoThinkWeb.FinishedModal do
  use Phoenix.Component

  attr :visible, :boolean, default: false
  attr :team_number, :string, required: true

  def finished_modal(assigns) do
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
            <span class="font-bold text-xl">Finished</span>
            <span class="text-sm text-gray-400 font-bold max-w-8/10 text-center">Thanks for participating on the Evaluation of my Master Thesis! Please fill out the Questionaire linked below! Thank you very much!</span>
            <span class="text-md font-medium">Your Teamnumber: <b><%= @team_number %></b></span>
            <a href={"https://docs.google.com/forms/d/e/1FAIpQLSeDLygkTAz_wiflWL4xm6-nr6ItXaTIfBVgLEfmqNRtKIbyPA/viewform?usp=pp_url&entry.2130834201=#{@team_number}"} target="_blank">
              <span class="flex flex-row gap-2 items-center justify-cente border-2 border-blue-300 rounded-md p-1 hover:bg-blue-100">
                <span class="text-md font-bold">Questionaire</span>
                <MaterialIcons.arrow_forward style="round" class="fill-blue-300" size={24} />
              </span>
            </a>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
