defmodule AlgoThinkWeb.StudyGroupLive.KeyGeneration do
  alias AlgoThink.StudyGroups
  alias AlgoThink.ChipStorage
  alias AlgoThink.CryptoArtifacts
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.accordion header="Key Generation" phx-click="accordion_toggled" phx-value-type={@type} open={@open}>
        <div class="flex flex-col gap-4">
          <form class="self-center" action="" phx-submit="generate_keys" phx-target={@myself} >
            <.button class="w-fit" disabled={@button_state == :loaded} type="submit">Generate Keys</.button>
          </form>
          <div class="flex flex-row gap-4">
            <.drop_zone id="drop-zone-public-key-result" placeholder={"Public Key"} is_result={true} crypto_artifact={@public_key} />
            <.drop_zone id="drop-zone-private-key-result" placeholder={"Private Key"} is_result={true} crypto_artifact={@private_key} />
          </div>
        </div>
      </.accordion>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do

    IO.inspect(Map.get(socket.assigns, :user_has_key_pair, nil))

    # check if user already generated public and private key!
    user_has_key_pair? = StudyGroups.user_has_key_pair?(assigns.current_user.id, assigns.study_group_id)

    {:ok,
     socket
      |> assign(assigns)
      |> assign(public_key: Enum.find(assigns.crypto_artifacts, fn crypto_artifact -> crypto_artifact.location_id == "drop-zone-public-key-result" end))
      |> assign(private_key: Enum.find(assigns.crypto_artifacts, fn crypto_artifact -> crypto_artifact.location_id == "drop-zone-private-key-result" end))
      |> assign(button_state: if user_has_key_pair? do :loaded else nil end)
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
    {:ok, %{:public_key => public_key, :private_key => private_key}} =
      CryptoArtifacts.generate_public_private_key_pair(socket.assigns.current_user.id)

    # add public key
    ChipStorage.create_crypto_artifact_user(%{
      user_id: socket.assigns.current_user.id,
      crypto_artifact_id: public_key.id,
      study_group_id: socket.assigns.study_group_id
    })

    # add private key
    ChipStorage.create_crypto_artifact_user(%{
      user_id: socket.assigns.current_user.id,
      crypto_artifact_id: private_key.id,
      study_group_id: socket.assigns.study_group_id
    })

    # set user has key pair in db
    StudyGroups.set_user_has_key_pair(socket.assigns.current_user.id, socket.assigns.study_group_id)

    send(self(), %{topic: "add_new_chip", crypto_artifact: public_key, location: socket.assigns.type, drop_zone_id: "drop-zone-public-key-result"})
    send(self(), %{topic: "add_new_chip", crypto_artifact: private_key, location: socket.assigns.type, drop_zone_id: "drop-zone-private-key-result"})

    {:noreply, socket}
  end

  @impl true
  def handle_event("start_drag", params, socket) do
    send(self(), %{topic: "start_drag", params: params, origin: socket.assigns.type})
    {:noreply, socket}
  end

  def handle_event("end_drag", params, socket) do
    send(self(), %{topic: "end_drag", params: params})
    {:noreply, socket}
  end
end
