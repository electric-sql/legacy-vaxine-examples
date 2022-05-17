defmodule AdvancedCounter.Counter do
  use Ecto.Schema

  @primary_key false
  schema "counters" do
    field :id, :string, primary_key: true
    field :value, :integer
  end
end
