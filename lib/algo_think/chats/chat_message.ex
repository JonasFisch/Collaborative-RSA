defmodule AlgoThink.ChatMessages.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :text, :string
    belongs_to :author, AlgoThink.Accounts.User
    belongs_to :study_group, AlgoThink.StudyGroups.StudyGroup

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:text, :author_id, :study_group_id])
    |> validate_required([:text, :author_id, :study_group_id])
  end
end