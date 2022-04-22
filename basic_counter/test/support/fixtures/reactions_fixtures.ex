defmodule Counters.ReactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Counters.Reactions` context.
  """

  @doc """
  Generate a reaction.
  """
  def reaction_fixture(attrs \\ %{}) do
    {:ok, reaction} =
      attrs
      |> Enum.into(%{
        count: 42
      })
      |> Counters.Reactions.create_reaction()

    reaction
  end
end
