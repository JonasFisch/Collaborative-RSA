defmodule AlgoThink.ChatMessages do
  @moduledoc """
  The ChatMessages context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.Repo

  alias AlgoThink.ChatMessages.ChatMessage
  alias AlgoThink.StudyGroups.StudyGroup

  @topic_prefix "study_group_"

  @doc """
  Returns the list of chat_messages.

  ## Examples

      iex> list_chat_messages()
      [%ChatMessage{}, ...]

  """
  def list_chat_messages(study_group_id) do
    study_group = Repo.get(StudyGroup, study_group_id)
      |> Repo.preload(:chat_messages)

    study_group.chat_messages |> Repo.preload(:author) |> Repo.preload(:attachment)
  end

  @doc """
  Gets a single chat_message.

  Raises if the Chat message does not exist.

  ## Examples

      iex> get_chat_message!(123)
      %ChatMessage{}

  """
  def get_chat_message!(id), do: Repo.get(ChatMessage, id)

  @doc """
  Creates a chat_message.

  ## Examples

      iex> create_chat_message(%{field: value})
      {:ok, %ChatMessage{}}

      iex> create_chat_message(%{field: bad_value})
      {:error, ...}

  """
  def create_chat_message(attrs \\ %{}) do
    {:ok, chat_message} = %ChatMessage{}
      |> ChatMessage.changeset(attrs)
      |> Repo.insert()

    chat_message = chat_message |> Repo.preload(:author)
    notify_subscribers({:ok, chat_message}, "new_message", attrs[:study_group_id])

    {:ok, chat_message}
  end

  @doc """
  Updates a chat_message.

  ## Examples

      iex> update_chat_message(chat_message, %{field: new_value})
      {:ok, %ChatMessage{}}

      iex> update_chat_message(chat_message, %{field: bad_value})
      {:error, ...}

  """
  def update_chat_message(%ChatMessage{} = chat_message, attrs) do
    chat_message
    |> ChatMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ChatMessage.

  ## Examples

      iex> delete_chat_message(chat_message)
      {:ok, %ChatMessage{}}

      iex> delete_chat_message(chat_message)
      {:error, ...}

  """
  def delete_chat_message(%ChatMessage{} = chat_message) do
    Repo.delete(chat_message)
  end

  @doc """
  Returns a data structure for tracking chat_message changes.

  ## Examples

      iex> change_chat_message(chat_message)
      %Todo{...}

  """
  def change_chat_message(%ChatMessage{} = chat_message, attrs \\ %{}) do
    ChatMessage.changeset(chat_message, attrs)
  end

  def notify_subscribers({:ok, result}, event, study_group_id) do
    AlgoThinkWeb.Endpoint.broadcast_from(
      self(),
      @topic_prefix <> study_group_id,
      event,
      result
    )

    {:ok, result}
  end

  def notify_subscribers(event, study_group_id) do
    notify_subscribers({:ok, nil}, event, study_group_id)
  end
end
