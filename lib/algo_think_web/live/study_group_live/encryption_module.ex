defmodule AlgoThinkWeb.StudyGroupLive.EncryptionModule do
  use AlgoThinkWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
        %{name: "Plain Message", crypto_artifact: crypto_artifact, placeholder: "Drop Message", expected_type: :message, encrypted: false, result: false},
        %{name: "Encrypt with", crypto_artifact: crypto_artifact, placeholder: "Drop Public Key", expected_type: :public_key, encrypted: false, result: false},
        %{name: "Encrypted Message", crypto_artifact: nil, placeholder: "Result", expected_type: :message, encrypted: true, result: true}
      ])
    }
  end

  @impl true
  def mount(socket) do
    {:ok, socket |> assign(data: [])}
  end
end
