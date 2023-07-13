defmodule AlgoThink.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :text, :string
      add :author_id, references(:users, on_delete: :nilify_all)
      add :study_group_id, references(:study_groups, on_delete: :delete_all)
      # add :attachment_id, references(:chips, on_delete: :delete_all)

      timestamps(type: :timestamptz)
    end
  end
end
