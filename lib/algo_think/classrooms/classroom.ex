defmodule AlgoThink.Classrooms.Classroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classroom" do
    field :name, :string
    field :token, :string

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
