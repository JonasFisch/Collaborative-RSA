defmodule AlgoThink.StudyGroups do
  @moduledoc """
  The StudyGroups context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.Classrooms
  alias AlgoThink.Classrooms.ClassroomUser
  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.Accounts.User
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
  def get_study_group!(id), do: Repo.get!(StudyGroup, id) |> Repo.preload(:users)

  def add_task_finished_state(study_group) do
    user_finished_task = Repo.aggregate(from(
      cu in ClassroomUser,
      where: cu.study_group_id == ^study_group.id and cu.task_done,
    ), :count)

    Map.put(study_group, :task_finished, user_finished_task)
  end

  def user_has_key_pair?(user_id, studygroup_id) do
    Repo.one(from(
      cu in ClassroomUser,
      where: cu.study_group_id == ^studygroup_id
        and cu.user_id == ^user_id,
      select: cu.has_key_pair
    ))
  end

  def set_user_has_key_pair(user_id, studygroup_id) do
    classroom_user = Repo.one(from(
      cu in ClassroomUser,
      where: cu.study_group_id == ^studygroup_id and cu.user_id == ^user_id
    ))

    if classroom_user == nil do
      raise "user has no classroom user relation!!!"
    end

    classroom_user
    |> ClassroomUser.changeset_update_has_key_pair(%{has_key_pair: true, task_done: true})
    |> Repo.update()
    |> Classrooms.notify_subscribers("classroom_updated")
  end

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
    |> StudyGroup.changeset(Map.put(attrs, :state, nil))
    |> Repo.insert()
  end

  def create_study_groups_for_classroom(%Classroom{} = classroom, name \\ "Group 1") do
    create_study_group(%{name: name, classroom_id: classroom.id})
  end

  def join_study_group(%Classroom{} = classroom, %User{} = user, study_group_id) do
    study_group = get_study_group!(study_group_id)
    classroom_user = Repo.one(from classroom_user in ClassroomUser, where: classroom_user.user_id == ^user.id and classroom_user.classroom_id == ^classroom.id)

    if not study_group_full(study_group) do
      result = classroom_user
        |> ClassroomUser.changeset_update(%{study_group_id: study_group.id})
        |> Repo.update()

      Classrooms.notify_subscribers("classroom_updated")

      {:ok, result}
    else
      {:error, "already full"}
    end
  end

  def join_no_group(%Classroom{} = classroom, %User{} = user) do

    classroom_user = Repo.one(from classroom_user in ClassroomUser, where: classroom_user.user_id == ^user.id and classroom_user.classroom_id == ^classroom.id)

    result = classroom_user
      |> ClassroomUser.changeset_update_no_group(%{study_group_id: nil})
      |> Repo.update()

    Classrooms.notify_subscribers("classroom_updated")

    {:ok, result}
  end

  def study_group_full(%StudyGroup{} = study_group) do
    length(study_group.users) >= study_group.max_users
  end

  def get_users_study_group(%User{} = user) do
    user = user |> Repo.preload(:study_groups)
    user.study_groups
  end


  def get_study_group_for_classroom(%User{} = user, %Classroom{} = classroom) do
    classroom_user = Repo.one(from classroom_user in ClassroomUser, where: classroom_user.user_id == ^user.id and classroom_user.classroom_id == ^classroom.id)
    classroom_user.study_group_id
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
