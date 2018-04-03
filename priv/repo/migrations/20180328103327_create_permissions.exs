defmodule Omscore.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :scope, :string
      add :action, :string
      add :object, :string
      add :description, :text
      add :always_assigned, :boolean, null: false, default: false

      timestamps()
    end

  end
end
