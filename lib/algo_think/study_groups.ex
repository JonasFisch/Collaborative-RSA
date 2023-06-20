defmodule AlgoThink.StudyGroups do
  @moduledoc """
  The StudyGroups context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.Repo

  alias AlgoThink.StudyGroups.StudyGroup

  @doc """
  Returns the list of study_groups.

  ## Examples

      iex> list_study_groups()
      [%StudyGroup{}, ...]

  """
  def list_study_groups do
    Repo.all(StudyGroup)
  end

  @doc """
  Gets a single study_group.

  Raises `Ecto.NoResultsError` if the Study group does not exist.

  ## Examples

      iex> get_study_group!(123)
      %StudyGroup{}

      iex> get_study_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_study_group!(id), do: Repo.get!(StudyGroup, id)

  @doc """
  Creates a study_group.

  ## Examples

      iex> create_study_group(%{field: value})
      {:ok, %StudyGroup{}}

      iex> create_study_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_study_group(attrs \\ %{}) do
    %StudyGroup{}
    |> StudyGroup.changeset(attrs)
    |> Repo.insert()
  end

  def create_study_groups_for_classroom(%Classroom{} = classroom, amount \\ 1) do
    IO.inspect(amount)
    IO.inspect(classroom)
    IO.inspect("study group created")
    create_study_group(%{name: "Group 1", classroom_id: classroom.id})
  end

  @doc """
  Updates a study_group.

  ## Examples

      iex> update_study_group(study_group, %{field: new_value})
      {:ok, %StudyGroup{}}

      iex> update_study_group(study_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_study_group(%StudyGroup{} = study_group, attrs) do
    study_group
    |> StudyGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a study_group.

  ## Examples

      iex> delete_study_group(study_group)
      {:ok, %StudyGroup{}}

      iex> delete_study_group(study_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_study_group(%StudyGroup{} = study_group) do
    Repo.delete(study_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking study_group changes.

  ## Examples

      iex> change_study_group(study_group)
      %Ecto.Changeset{data: %StudyGroup{}}

  """
  def change_study_group(%StudyGroup{} = study_group, attrs \\ %{}) do
    StudyGroup.changeset(study_group, attrs)
  end
end
