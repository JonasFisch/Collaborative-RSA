defmodule AlgoThinkWeb.PageController do
  use AlgoThinkWeb, :controller
  alias AlgoThink.PerformanceLogs

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/classroom")
    render(conn, :home, layout: false)
  end

  def latency(conn, _params) do
    latency_logs = PerformanceLogs.list_latency_logs()

    latency_sum = Enum.reduce(latency_logs, 0, fn latency_log, acc ->
      acc + latency_log.latency
    end)

    text conn, "#{latency_sum / length(latency_logs)} ms"
  end
end
