defmodule AlgoThink.ClassroomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AlgoThink.Classrooms` context.
  """

  @doc """
  Generate a classroom.
  """
  def classroom_fixture(attrs \\ %{}) do
    {:ok, classroom} =
      attrs
      |> Enum.into(%{

      })
      |> AlgoThink.Classrooms.create_classroom()

    classroom
  end
end
