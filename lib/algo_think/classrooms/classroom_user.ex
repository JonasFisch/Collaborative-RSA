defmodule AlgoThink.Classrooms.ClassroomUser do
  @moduledoc "ClassroomUser"

  use Ecto.Schema
  import Ecto.Changeset

  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.StudyGroups.StudyGroup
  alias AlgoThink.Accounts.User

  schema "classroom_users" do
    belongs_to(:user, User)
    belongs_to(:classroom, Classroom)
    belongs_to(:study_group, StudyGroup)

    timestamps()
  end

  @doc false
  def changeset(classroom_user, attrs) do
    classroom_user
    |> cast(attrs, [:user_id, :classroom_id, :study_group_id])
    |> validate_required([:user_id, :classroom_id])
    |> unique_constraint([:user_id, :classroom_id], name: :classroom_user_unique)
  end

  def changeset_update(classroom_user, attrs) do
    classroom_user
    |> cast(attrs, [:study_group_id])
    |> validate_required([:study_group_id])
  end
end
