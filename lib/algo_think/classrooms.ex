defmodule AlgoThink.Classrooms do
  @moduledoc """
  The Classrooms context.
  """

  import Ecto.Query, warn: false
  alias AlgoThink.StudyGroups
  alias AlgoThink.Repo

  alias AlgoThink.Accounts.User
  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.Classrooms.ClassroomUser
  alias AlgoThink.StudyGroups.StudyGroup

  @topic "classroom"

  @doc """
  Returns the list of classroom.

  ## Examples

      iex> list_classroom()
      [%Classroom{}, ...]

  """
  def list_classroom do
    Repo.all(Classroom)
  end

  def list_classroom_for_owner(%User{} = user) do
    user = user |> Repo.preload(:classrooms)

    user.classrooms
  end

  @doc """
  Gets a single classroom.

  Raises `Ecto.NoResultsError` if the Classroom does not exist.

  ## Examples

      iex> get_classroom!(123)
      %Classroom{}

      iex> get_classroom!(456)
      ** (Ecto.NoResultsError)

  """
  def get_classroom!(id) do
    study_group_users_query =
      from(
        sg in StudyGroup,
        order_by: [asc: sg.name],
        preload: [:users]
      )

    Repo.get!(Classroom, id) |> Repo.preload([:users]) |> Repo.preload(study_groups: study_group_users_query)
  end

  @spec get_classroom_by_token(binary) :: {:ok, any}
  def get_classroom_by_token(token) when is_binary(token), do: {:ok, Repo.get_by(Classroom, token: token)}

  def students_with_no_study_group(id) do
    Repo.all(from(
      user in User,
      join: cu in ClassroomUser,
      on: cu.user_id == user.id,
      where: cu.classroom_id == ^id and is_nil(cu.study_group_id) and user.role == :student
    ))
  end

  def add_user_classroom(%User{} = user, %Classroom{} = classroom) do
    %ClassroomUser{}
    |> ClassroomUser.changeset(%{"user_id" => user.id, "classroom_id" => classroom.id})
    |> Repo.insert()
  end

  def classroom_join_by_token(%User{} = user, token) do
    case get_classroom_by_token(token) do
      {:ok, %Classroom{} = classroom} ->
        case add_user_classroom(user, classroom) do
          {:ok, %ClassroomUser{} = classroom_user} ->
            notify_subscribers("classroom_updated")
            {:ok, classroom_user}
          {:error, _changeset} ->
            {:error, "already joined!"}
        end
      {:ok, nil} ->
        {:error, "invalid token!"}
    end
  end

  @doc """
  Creates a classroom.

  ## Examples

      iex> create_classroom(%{field: value})
      {:ok, %Classroom{}}

      iex> create_classroom(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_classroom(attrs \\ %{}, %User{} = user) do
    {:ok, classroom} =
      %Classroom{}
      |> Classroom.changeset(Map.put(attrs, "state", :group_finding))
      |> Repo.insert()

    add_user_classroom(user, classroom)
    StudyGroups.create_study_groups_for_classroom(classroom, "Group 1")
    StudyGroups.create_study_groups_for_classroom(classroom, "Group 2")
    StudyGroups.create_study_groups_for_classroom(classroom, "Group 3")

    {:ok, classroom}
  end



  @doc """
  Updates a classroom.

  ## Examples

      iex> update_classroom(classroom, %{field: new_value})
      {:ok, %Classroom{}}

      iex> update_classroom(classroom, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_classroom(%Classroom{} = classroom, attrs) do
    classroom
    |> Classroom.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers("classroom_updated")
  end

  @doc """
  Deletes a classroom.

  ## Examples

      iex> delete_classroom(classroom)
      {:ok, %Classroom{}}

      iex> delete_classroom(classroom)
      {:error, %Ecto.Changeset{}}

  """
  def delete_classroom(%Classroom{} = classroom) do
    Repo.delete(classroom)
    |> notify_subscribers("classroom_deleted")
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking classroom changes.

  ## Examples

      iex> change_classroom(classroom)
      %Ecto.Changeset{data: %Classroom{}}

  """
  def change_classroom(%Classroom{} = classroom, attrs \\ %{}) do
    Classroom.changeset(classroom, attrs)
  end

  def notify_subscribers({:ok, result}, event) do
    AlgoThinkWeb.Endpoint.broadcast_from(
      self(),
      @topic,
      event,
      result
    )

    if not is_nil(result) do
      AlgoThinkWeb.Endpoint.broadcast_from(
        self(),
        @topic <> "#{result.id}",
        event,
        result
      )
    end

    {:ok, result}
  end

  def notify_subscribers(event) do
    notify_subscribers({:ok, nil}, event)
  end

  # defp notify_subscribers({:error, reason}, _), do: {:error, reason}

end
