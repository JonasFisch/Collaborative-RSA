defmodule AlgoThink.PerformanceLogs do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.ChatMessages
  alias AlgoThink.MessageLatencyLog
  alias AlgoThink.UserTaskLog
  alias AlgoThink.Repo

  def log_user_task(user_id, task, type) do
    Task.start(fn ->
      %UserTaskLog{}
      |> UserTaskLog.changeset(%{user_id: user_id, task: task, type: type})
      |> Repo.insert()
    end)
  end

  def log_user_started_task(user_id, task) do log_user_task(user_id, task, :started) end
  def log_user_ended_task(user_id, task) do log_user_task(user_id, task, :ended)

  end

  def log_message_latency(user_id, message_id) do
    now = Time.utc_now()

    message = ChatMessages.get_chat_message!(message_id)
    {:ok, creation_time} = Time.from_iso8601(message.precise_creation_time)
    latency = Time.diff(now, creation_time, :millisecond)

    %MessageLatencyLog{}
    |> MessageLatencyLog.changeset(%{latency: latency, user_id: user_id})
    |> Repo.insert()
  end
end
