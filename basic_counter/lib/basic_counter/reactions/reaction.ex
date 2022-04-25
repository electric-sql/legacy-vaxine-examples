defmodule Counters.Reactions.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "reactions" do
    field :id, :string, primary_key: true
    field :count, :integer
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:count])
    |> validate_required([:count])
  end
end
