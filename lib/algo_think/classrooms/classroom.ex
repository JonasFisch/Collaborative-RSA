defmodule AlgoThink.Classrooms.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias AlgoThink.Accounts.User

  schema "classroom" do
    field :name, :string
    field :token, :string

    many_to_many :users, User, join_through: "classroom_users", on_replace: :delete

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
