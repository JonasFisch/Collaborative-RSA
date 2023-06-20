defmodule AlgoThink.StudyGroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AlgoThink.StudyGroups` context.
  """

  @doc """
  Generate a study_group.
  """
  def study_group_fixture(attrs \\ %{}) do
    {:ok, study_group} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> AlgoThink.StudyGroups.create_study_group()

    study_group
  end
end
