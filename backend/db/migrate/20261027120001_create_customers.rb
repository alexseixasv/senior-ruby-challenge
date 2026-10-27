class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :external_crm_id
      t.timestamps
    end

    add_index :customers, %i[account_id email]
    add_index :customers, :external_crm_id
  end
end
