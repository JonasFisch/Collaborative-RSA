defmodule AlgoThinkWeb.StudyGroupLive.KeyGeneration do
  alias AlgoThink.ChipStorage
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.accordion header="Key Generation">
        <div class="flex flex-col gap-4">
          <form class="self-center" action="" phx-submit="generate_keys" phx-target={@myself} >
            <.button class="w-fit" disabled={@button_state == :loaded} type="submit">Generate Keys</.button>
          </form>
          <div class="flex flex-row gap-4">
            <.drop_zone id="result-key-generation-public" phx-click="add_key_to_storage" phx-target={@myself} placeholder={"Public Key"} is_result={true} crypto_artifact={@public_key} />
            <.drop_zone id="result-key-generation-private" phx-click="add_key_to_storage" phx-target={@myself} placeholder={"Private Key"} is_result={true} crypto_artifact={@private_key} />
          </div>
        </div>
      </.accordion>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
      |> assign(assigns)
    }
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(
      button_state: nil,
      public_key: nil,
      private_key: nil
    )}
  end

  @impl true
  def handle_event("generate_keys", _params, socket) do
    {:ok, %{:public_key => public_key, :private_key => private_key}} = CryptoArtifacts.generate_public_private_key_pair(socket.assigns.current_user.id)

    {:noreply, socket |> assign(
        button_state: :loaded,
        public_key: public_key,
        private_key: private_key
    )}
  end

  @impl true
  def handle_event("add_key_to_storage", params, socket) do
    ChipStorage.create_crypto_artifact_user(%{
      user_id: socket.assigns.current_user.id,
      crypto_artifact_id: params["crypto-artifact-id"],
      study_group_id: socket.assigns.study_group_id
    })

    assigns = case params["crypto-artifact-type"] do
      "public_key" -> %{public_key: nil}
      "private_key" -> %{private_key: nil}
      _ -> raise "invalid type given! in key generation"
    end

    # TODO: use add chip here!
    send(self(), "load_users_chips")

    {:noreply, socket |> assign(assigns)}
  end
end
