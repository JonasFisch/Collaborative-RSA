defmodule AlgoThinkWeb.PageController do
  use AlgoThinkWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    redirect(conn, to: ~p"/classroom")
    render(conn, :home, layout: false)
  end
end
