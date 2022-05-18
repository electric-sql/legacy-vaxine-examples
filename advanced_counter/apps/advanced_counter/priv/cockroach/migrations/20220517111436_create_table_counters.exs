defmodule AdvancedCounter.Repos.CloudSql.Migrations.CreateTableCounters do
  use Ecto.Migration

  def change do
    create table("counters", primary_key: false) do
      add :id, :string, primary_key: true
      add :value, :integer
    end
  end
end
