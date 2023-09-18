defmodule AlgoThink.PerformanceLogs do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.TaskMistakeLog
  alias AlgoThink.ChatMessages
  alias AlgoThink.MessageLatencyLog
  alias AlgoThink.UserTaskLog
  alias AlgoThink.Repo


  def list_latency_logs do
    Repo.all(MessageLatencyLog)
  end

  def get_latency_logs_for_user(user_id) do
    from(log in MessageLatencyLog, where: log.user_id == ^user_id) |> Repo.all()
  end

  def get_task_time_logs_for_task(user_id, task, type) do
    from(log in UserTaskLog, where: log.user_id == ^user_id and log.task == ^task and log.type == ^type) |> Repo.all()
  end


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

  def log_task_mistakes(study_group_id, mistakes, task) do
    %TaskMistakeLog{}
    |> TaskMistakeLog.changeset(%{mistakes: mistakes, study_group_id: study_group_id, task: task})
    |> Repo.insert()
  end
end
