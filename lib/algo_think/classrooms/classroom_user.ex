defmodule AlgoThink.Classrooms.ClassroomUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.Accounts.User

  schema "classroom_users" do
    belongs_to(:user, User)
    belongs_to(:classroom, Classroom)

    timestamps()
  end

  @doc false
  def changeset(classroom_user, attrs) do
    classroom_user
    |> cast(attrs, [:user_id, :classroom_id])
    |> validate_required([:user_id, :classroom_id])
    |> unique_constraint([:user_id, :classroom_id], name: :classroom_user_unique)
  end
end
