defmodule Mix.Tasks.CalcLatency do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Echoes arguments"
alias AlgoThink.PerformanceLogs

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    latency_logs = PerformanceLogs.list_latency_logs()

    latency_sum = Enum.reduce(latency_logs, 0, fn latency_log, acc ->
      acc + latency_log.latency
    end)

    Mix.shell().info(latency_sum)
  end
end
