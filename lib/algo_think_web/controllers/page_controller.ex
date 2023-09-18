defmodule AlgoThinkWeb.PageController do
  use AlgoThinkWeb, :controller
  alias AlgoThink.Accounts
  alias AlgoThink.PerformanceLogs

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/classroom")
    render(conn, :home, layout: false)
  end

  def latency(conn, _params) do

    for user <- Accounts.list_users do

      latency_logs = PerformanceLogs.get_latency_logs_for_user(user.id)

      latency_sum = Enum.reduce(latency_logs, 0, fn latency_log, acc ->
        acc + latency_log.latency
      end)

      if (length(latency_logs) > 0) do
        average_latency = latency_sum / length(latency_logs)
        max_latency = Enum.map(latency_logs, fn log -> log.latency end) |> Enum.max()

        IO.inspect("user_id: #{user.id} | average latency: #{average_latency} | highest latency: #{max_latency} ")
      end
    end

    text conn, "done"
  end

  def time_per_task(conn, _params) do
    for user <- Accounts.list_users do

      for task <- [:key_gen, :rsa, :rsa_with_signatures] do
        start_time = Enum.reduce(PerformanceLogs.get_task_time_logs_for_task(user.id, task, :started), nil, fn log, acc ->
          if (is_nil(acc)) do
            log
          else
            if (log.inserted_at < acc.inserted_at) do
              log
            else
              acc
            end
          end
        end)

        end_time = Enum.reduce(PerformanceLogs.get_task_time_logs_for_task(user.id, task, :ended), nil, fn log, acc ->
          if (is_nil(acc)) do
            log
          else
            if (log.inserted_at < acc.inserted_at) do
              log
            else
              acc
            end
          end
        end)

        if(not is_nil(start_time) and not is_nil(end_time)) do
          diff = Time.diff(start_time.inserted_at, end_time.inserted_at, :second)
          IO.inspect("user_id: #{user.id} | task: #{task} | diff: #{diff} s")
        end
      end


      # if (length(latency_logs) > 0) do
      #   average_latency = latency_sum / length(latency_logs)
      #   max_latency = Enum.map(latency_logs, fn log -> log.latency end) |> Enum.max()

      # end
    end

    text conn, "done"

  end
end
