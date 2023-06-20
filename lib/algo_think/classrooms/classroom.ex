defmodule AlgoThink.Classrooms.Classroom do
  @moduledoc "Classroom"

  use Ecto.Schema
  import Ecto.Changeset
  alias AlgoThink.Accounts.User
  alias AlgoThink.StudyGroups.StudyGroup

  schema "classrooms" do
    field :name, :string
    field :token, :string

    many_to_many :users, User, join_through: "classroom_users", on_replace: :delete
    has_many :study_groups, StudyGroup

    timestamps()
  end

  @doc false
  def changeset(classroom, attrs) do
    classroom
    |> cast(attrs, [:name, :token])
    |> validate_required([:name, :token])
    |> unique_constraint(:token)
  end
end
