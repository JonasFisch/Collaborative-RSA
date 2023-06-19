defmodule AlgoThink.Classrooms do
  @moduledoc """
  The Classrooms context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias AlgoThink.Repo

  alias AlgoThink.Accounts.User
  alias AlgoThink.Classrooms.Classroom
  alias AlgoThink.Classrooms.ClassroomUser

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
    Repo.get!(Classroom, id) |> Repo.preload(:users)
  end

  defp get_classroom_by_token(token) when is_binary(token), do: Repo.get_by(Classroom, token: token)

  def add_user_classroom(%User{} = user, %Classroom{} = classroom) do
    %ClassroomUser{}
    |> ClassroomUser.changeset(%{"user_id" => user.id, "classroom_id" => classroom.id})
    |> Repo.insert()
  end

  def classroom_join_by_token(%User{} = _user, token) do
    case get_classroom_by_token(token) do
      {%Classroom{} = classroom} ->
        {:ok, classroom}
      :nil ->
        {:error, "token not found"}
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
      |> Classroom.changeset(attrs)
      |> Repo.insert()

    add_user_classroom(user, classroom)

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

  def change_classroom_join(%Classroom{} = classroom, attrs \\ %{}) do
    Classroom.token_changeset(classroom, attrs)
  end
end
