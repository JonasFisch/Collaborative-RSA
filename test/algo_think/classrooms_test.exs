defmodule AlgoThink.ClassroomsTest do
  use AlgoThink.DataCase

  alias AlgoThink.Classrooms

  describe "classroom" do
    alias AlgoThink.Classrooms.Classroom

    import AlgoThink.ClassroomsFixtures

    @invalid_attrs %{}

    test "list_classroom/0 returns all classroom" do
      classroom = classroom_fixture()
      assert Classrooms.list_classroom() == [classroom]
    end

    test "get_classroom!/1 returns the classroom with given id" do
      classroom = classroom_fixture()
      assert Classrooms.get_classroom!(classroom.id) == classroom
    end

    test "create_classroom/1 with valid data creates a classroom" do
      valid_attrs = %{}

      assert {:ok, %Classroom{} = classroom} = Classrooms.create_classroom(valid_attrs)
    end

    test "create_classroom/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classrooms.create_classroom(@invalid_attrs)
    end

    test "update_classroom/2 with valid data updates the classroom" do
      classroom = classroom_fixture()
      update_attrs = %{}

      assert {:ok, %Classroom{} = classroom} = Classrooms.update_classroom(classroom, update_attrs)
    end

    test "update_classroom/2 with invalid data returns error changeset" do
      classroom = classroom_fixture()
      assert {:error, %Ecto.Changeset{}} = Classrooms.update_classroom(classroom, @invalid_attrs)
      assert classroom == Classrooms.get_classroom!(classroom.id)
    end

    test "delete_classroom/1 deletes the classroom" do
      classroom = classroom_fixture()
      assert {:ok, %Classroom{}} = Classrooms.delete_classroom(classroom)
      assert_raise Ecto.NoResultsError, fn -> Classrooms.get_classroom!(classroom.id) end
    end

    test "change_classroom/1 returns a classroom changeset" do
      classroom = classroom_fixture()
      assert %Ecto.Changeset{} = Classrooms.change_classroom(classroom)
    end
  end
end
