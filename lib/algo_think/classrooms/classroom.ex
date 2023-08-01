defmodule AlgoThink.Classrooms.Classroom do
  @moduledoc "Classroom"

  use Ecto.Schema
  import Ecto.Changeset
  alias AlgoThink.Accounts.User
  alias AlgoThink.StudyGroups.StudyGroup

  @states [:group_finding, :running, :finished]

  schema "classrooms" do
    field :name, :string
    field :token, :string
    field :state, Ecto.Enum, values: @states

    many_to_many :users, User, join_through: "classroom_users", on_replace: :delete
    has_many :study_groups, StudyGroup

    timestamps()
  end

  @doc false
  def changeset(classroom, attrs) do
    classroom
    |> cast(attrs, [:name, :token, :state])
    |> validate_required([:name, :token])
    |> unique_constraint(:token)
    |> validate_inclusion(:state, @states)
  end
end
