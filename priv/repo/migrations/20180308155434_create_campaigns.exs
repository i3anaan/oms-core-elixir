defmodule Omscore.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add :name, :string
      add :url, :string, null: false
      add :active, :boolean, default: false, null: false
      add :description_short, :string, size: 400
      add :description_long, :text
      add :activate_user, :boolean, default: false, null: false
      add :autojoin_body_id, :integer

      timestamps()
    end

    create unique_index(:campaigns, [:url])
  end
end
