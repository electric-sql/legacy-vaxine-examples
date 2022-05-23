defmodule AdvancedCounter.VaxCounter do
  use Vax.Schema
  import Ecto.Changeset
  alias Vax.Types.Counter

  @primary_key false
  schema "counters" do
    field :id, :string, primary_key: true
    field :value, Counter
  end

  def increment(data, amount \\ 1) do
    data
    |> change()
    |> Counter.cast_increment(:value, amount)
  end
end
