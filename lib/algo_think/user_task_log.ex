defmodule AlgoThink.UserTaskLog do
  use Ecto.Schema
  import Ecto.Changeset

  @types [:started, :ended]
  @tasks [:key_gen, :rsa, :rsa_with_signatures]

  schema "user_task_logs" do
    field :type, Ecto.Enum, values: @types
    field :task, Ecto.Enum, values: @tasks

    belongs_to :user, AlgoThink.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_log, attrs) do
    user_log
    |> cast(attrs, [:type, :user_id, :task])
    |> validate_required([:type, :user_id, :task])
    |> validate_inclusion(:type, @types)
    |> validate_inclusion(:task, @tasks)
  end
end
