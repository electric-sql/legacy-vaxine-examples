defmodule Counters.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :string, primary_key: true
      add :count, :integer, null: false
    end
  end
end
