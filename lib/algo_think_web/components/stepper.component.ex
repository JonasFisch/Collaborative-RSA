defmodule AlgoThinkWeb.Stepper do
  use Phoenix.Component

  @states [:group_finding, :key_gen, :rsa, :rsa_with_evil, :rsa_with_signatures, :finished]

  attr :current_state, :atom, values: @states

  def stepper(assigns) do
    assigns = Map.put(assigns, :states, @states)

    ~H"""
    <ol>
      <%= for {state, index} <- Enum.with_index(@states) do %>
        <li class="pb-10 relative">
          <div class="flex flex-row gap-4 items-center">
            <div class={[
              "border-2 border-gray-200 rounded-full w-10 h-10 bg-white z-20 flex flex-row justify-center items-center",
              if index < Enum.find_index(@states, &(&1 == @current_state)) do
                "border-green-300 !bg-green-300"
              end,
              if index == Enum.find_index(@states, &(&1 == @current_state)) do
                "border-green-300"
              end
            ]}>
              <MaterialIcons.check class="fill-white" size={28} :if={index < Enum.find_index(@states, &(&1 == @current_state))}/>
              <div class="rounded-full bg-green-300 h-4 w-4" :if={index == Enum.find_index(@states, &(&1 == @current_state))} />
            </div>
            <span>
            <%= case state do
              :group_finding -> "Waiting for all Students to join."
              :key_gen -> "Key Generation"
              :rsa -> "RSA"
              :rsa_with_evil -> "RSA with Evil"
              :rsa_with_signatures -> "RSA with Signatures"
              :finished -> "Finished"
              _ -> "Waiting ..."
            end %>
            </span>
          </div>
          <div class={[
            "w-0.5 h-full bg-gray-200 absolute top-6 left-5 -translate-x-1/2 z-10",
            if index < Enum.find_index(@states, &(&1 == @current_state)) do
              "!bg-green-300"
            end
          ]} :if={length(@states) > index + 1}>
          </div>
        </li>
      <% end %>
    </ol>
    """
  end
end
