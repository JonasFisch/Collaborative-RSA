defmodule AlgoThink.TaskMistakeLog do
  use Ecto.Schema
  import Ecto.Changeset

  @tasks [:key_gen, :rsa, :rsa_with_signatures]

  schema "task_mistake_logs" do
    field :mistakes, :integer
    field :study_group_id, :id
    field :task, Ecto.Enum, values: @tasks

    timestamps()
  end

  @doc false
  def changeset(task_mistake_log, attrs) do
    task_mistake_log
    |> cast(attrs, [:mistakes, :study_group_id, :task])
    |> validate_required([:mistakes, :task, :study_group_id])
    |> validate_inclusion(:task, @tasks)
  end
end
