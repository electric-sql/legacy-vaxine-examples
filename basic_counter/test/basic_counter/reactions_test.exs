defmodule Counters.ReactionsTest do
  use Counters.DataCase

  alias Counters.Reactions

  describe "reactions" do
    alias Counters.Reactions.Reaction

    import Counters.ReactionsFixtures

    @invalid_attrs %{count: nil}

    test "list_reactions/0 returns all reactions" do
      reaction = reaction_fixture()
      assert Reactions.list_reactions() == [reaction]
    end

    test "get_reaction!/1 returns the reaction with given id" do
      reaction = reaction_fixture()
      assert Reactions.get_reaction!(reaction.id) == reaction
    end

    test "create_reaction/1 with valid data creates a reaction" do
      valid_attrs = %{count: 42}

      assert {:ok, %Reaction{} = reaction} = Reactions.create_reaction(valid_attrs)
      assert reaction.count == 42
    end

    test "create_reaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reactions.create_reaction(@invalid_attrs)
    end

    test "update_reaction/2 with valid data updates the reaction" do
      reaction = reaction_fixture()
      update_attrs = %{count: 43}

      assert {:ok, %Reaction{} = reaction} = Reactions.update_reaction(reaction, update_attrs)
      assert reaction.count == 43
    end

    test "update_reaction/2 with invalid data returns error changeset" do
      reaction = reaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Reactions.update_reaction(reaction, @invalid_attrs)
      assert reaction == Reactions.get_reaction!(reaction.id)
    end

    test "delete_reaction/1 deletes the reaction" do
      reaction = reaction_fixture()
      assert {:ok, %Reaction{}} = Reactions.delete_reaction(reaction)
      assert_raise Ecto.NoResultsError, fn -> Reactions.get_reaction!(reaction.id) end
    end

    test "change_reaction/1 returns a reaction changeset" do
      reaction = reaction_fixture()
      assert %Ecto.Changeset{} = Reactions.change_reaction(reaction)
    end
  end
end
