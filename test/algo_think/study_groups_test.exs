defmodule AlgoThink.StudyGroupsTest do
  use AlgoThink.DataCase

  alias AlgoThink.StudyGroups

  describe "study_groups" do
    alias AlgoThink.StudyGroups.StudyGroup

    import AlgoThink.StudyGroupsFixtures

    @invalid_attrs %{name: nil}

    test "list_study_groups/0 returns all study_groups" do
      study_group = study_group_fixture()
      assert StudyGroups.list_study_groups() == [study_group]
    end

    test "get_study_group!/1 returns the study_group with given id" do
      study_group = study_group_fixture()
      assert StudyGroups.get_study_group!(study_group.id) == study_group
    end

    test "create_study_group/1 with valid data creates a study_group" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %StudyGroup{} = study_group} = StudyGroups.create_study_group(valid_attrs)
      assert study_group.name == "some name"
    end

    test "create_study_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StudyGroups.create_study_group(@invalid_attrs)
    end

    test "update_study_group/2 with valid data updates the study_group" do
      study_group = study_group_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %StudyGroup{} = study_group} = StudyGroups.update_study_group(study_group, update_attrs)
      assert study_group.name == "some updated name"
    end

    test "update_study_group/2 with invalid data returns error changeset" do
      study_group = study_group_fixture()
      assert {:error, %Ecto.Changeset{}} = StudyGroups.update_study_group(study_group, @invalid_attrs)
      assert study_group == StudyGroups.get_study_group!(study_group.id)
    end

    test "delete_study_group/1 deletes the study_group" do
      study_group = study_group_fixture()
      assert {:ok, %StudyGroup{}} = StudyGroups.delete_study_group(study_group)
      assert_raise Ecto.NoResultsError, fn -> StudyGroups.get_study_group!(study_group.id) end
    end

    test "change_study_group/1 returns a study_group changeset" do
      study_group = study_group_fixture()
      assert %Ecto.Changeset{} = StudyGroups.change_study_group(study_group)
    end
  end
end
