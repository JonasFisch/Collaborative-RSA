defmodule AlgoThink.StudyGroups.StudyGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "study_groups" do
    field :name, :string
    belongs_to :classroom, AlgoThink.Classrooms.Classroom

    timestamps()
  end

  @doc false
  def changeset(study_group, attrs) do
    study_group
    |> cast(attrs, [:name, :classroom_id])
    |> validate_required([:name, :classroom_id])
  end
end
