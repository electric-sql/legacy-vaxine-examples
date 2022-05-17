defmodule Counters.Reactions.Reaction do
  use Vax.Schema
  import Ecto.Changeset

  @primary_key false
  schema "reactions" do
    field :id, :string, primary_key: true
    field :count, Vax.Types.Counter
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:count])
    |> validate_required([:count])
  end

  def increment(reaction, amount \\ 1) do
    reaction
    |> change()
    |> Vax.Types.Counter.cast_increment(:count, 1)
  end
end
