defmodule AlgoThink.MessageLatencyLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "message_latency_logs" do
    field :latency, :integer
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(message_latency_log, attrs) do
    message_latency_log
    |> cast(attrs, [:latency, :user_id])
    |> validate_required([:latency, :user_id])
  end
end
