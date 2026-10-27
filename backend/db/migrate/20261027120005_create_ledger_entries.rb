class CreateLedgerEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :ledger_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.references :payment_event, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :entry_type, null: false
      t.string :external_event_id, null: false
      t.timestamps
    end

    add_index :ledger_entries, :external_event_id
    add_check_constraint :ledger_entries, "amount_cents > 0", name: "ledger_entries_amount_cents_positive"
  end
end
