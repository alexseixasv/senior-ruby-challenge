class CreateExtractionRuns < ActiveRecord::Migration[7.2]
  def change
    create_table :extraction_runs do |t|
      t.references :account, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.string :outcome, null: false
      t.string :provider_name, null: false
      t.jsonb :result, null: false, default: {}
      t.timestamps
    end
  end
end
