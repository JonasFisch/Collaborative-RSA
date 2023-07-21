defmodule AlgoThinkWeb.StudyGroupLive.EncryptionModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div phx-hook="drag" id="drag">
      <.crypto_module name="Encryption" fields={@data} />
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do

    crypto_artifact = Enum.at(assigns.crypto_artifacts, 0, nil)

    {:ok,
     socket
      |> assign(assigns)
      |> assign(:errors, [])
      |> assign(:data, [
        %{drop_zone_id: "drop-zone-encryption-message", name: "Plain Message", crypto_artifact: crypto_artifact, placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
        %{drop_zone_id: "drop-zone-encryption-public-key", name: "Encrypt with", crypto_artifact: crypto_artifact, placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
        %{drop_zone_id: "drop-zone-encryption-result", name: "Encrypted Message", crypto_artifact: nil, placeholder: "Result", expected_type: :message, encrypted: true, result: true}
      ])
    }
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(data: [])}
  end

  def handle_event("dropped", params, socket) do
    IO.inspect(params)
    IO.inspect("in dropped in encryption module")

    {:noreply, socket}
  end

end
