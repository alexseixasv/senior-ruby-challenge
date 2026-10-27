class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :account, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.integer :amount_cents, null: false
      t.string :status, null: false, default: "pending"
      t.text :description
      t.datetime :processed_at
      t.timestamps
    end

    add_index :invoices, %i[account_id invoice_number], unique: true
    add_index :invoices, %i[account_id status]
    add_index :invoices, :created_at
    add_check_constraint :invoices, "amount_cents > 0", name: "invoices_amount_cents_positive"
    add_check_constraint :invoices,
                         "status IN ('pending', 'processing', 'processed', 'failed')",
                         name: "invoices_status_allowed"
  end
end
