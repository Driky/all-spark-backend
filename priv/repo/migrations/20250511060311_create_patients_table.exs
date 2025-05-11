defmodule Pantheon.Repo.Migrations.CreatePatientsTable do
  use Ecto.Migration

  def change do
    create table(:patients, primary_key: false) do
      add :patient_id, :uuid, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :date_of_birth, :date
      add :email, :string, null: false
      add :phone, :string
      add :address, :string
      add :nutritionist_id, :string, null: false

      timestamps()
    end

    create index(:patients, [:nutritionist_id])
    create index(:patients, [:email])
  end
end
