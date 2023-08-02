defmodule AlgoThink.StudyGroups.StudyGroup do
  @moduledoc "StudyGroup"

  use Ecto.Schema
  import Ecto.Changeset

  @states [:key_gen, :rsa, :rsa_with_evil, :rsa_with_signatures]

  schema "study_groups" do
    field :name, :string
    field :max_users, :integer, default: 4
    field :state, Ecto.Enum, values: @states
    field :task_finished, :integer, virtual: true

    belongs_to :classroom, AlgoThink.Classrooms.Classroom
    many_to_many :users, AlgoThink.Accounts.User, join_through: "classroom_users"
    has_many :chat_messages, AlgoThink.ChatMessages.ChatMessage

    timestamps()
  end

  @doc false
  def changeset(study_group, attrs) do
    study_group
    |> cast(attrs, [:name, :classroom_id, :max_users, :state])
    |> validate_required([:name, :classroom_id])
    |> validate_inclusion(:state, @states)
  end
end
