class CreatePaymentEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_events do |t|
      t.references :account, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :external_event_id, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}
      t.datetime :processed_at
      t.timestamps
    end

    add_index :payment_events, %i[provider external_event_id]
  end
end
