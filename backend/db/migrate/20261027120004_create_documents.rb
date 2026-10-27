class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.references :account, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :extracted_data
      t.timestamps
    end

    add_index :documents, %i[account_id status]
    add_check_constraint :documents,
                         "status IN ('pending', 'processing', 'processed', 'failed')",
                         name: "documents_status_allowed"
  end
end
