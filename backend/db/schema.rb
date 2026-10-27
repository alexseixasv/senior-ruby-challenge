# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_10_27_120006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "external_crm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_customers_on_account_id_and_email"
    t.index ["account_id"], name: "index_customers_on_account_id"
    t.index ["external_crm_id"], name: "index_customers_on_external_crm_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "invoice_id", null: false
    t.string "filename", null: false
    t.string "status", default: "pending", null: false
    t.jsonb "extracted_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_documents_on_account_id_and_status"
    t.index ["account_id"], name: "index_documents_on_account_id"
    t.index ["invoice_id"], name: "index_documents_on_invoice_id"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'processed'::character varying, 'failed'::character varying]::text[])", name: "documents_status_allowed"
  end

  create_table "extraction_runs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "document_id", null: false
    t.string "outcome", null: false
    t.string "provider_name", null: false
    t.jsonb "result", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_extraction_runs_on_account_id"
    t.index ["document_id"], name: "index_extraction_runs_on_document_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "customer_id", null: false
    t.string "invoice_number", null: false
    t.integer "amount_cents", null: false
    t.string "status", default: "pending", null: false
    t.text "description"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "invoice_number"], name: "index_invoices_on_account_id_and_invoice_number", unique: true
    t.index ["account_id", "status"], name: "index_invoices_on_account_id_and_status"
    t.index ["account_id"], name: "index_invoices_on_account_id"
    t.index ["created_at"], name: "index_invoices_on_created_at"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.check_constraint "amount_cents > 0", name: "invoices_amount_cents_positive"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'processed'::character varying, 'failed'::character varying]::text[])", name: "invoices_status_allowed"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "invoice_id", null: false
    t.bigint "payment_event_id"
    t.integer "amount_cents", null: false
    t.string "entry_type", null: false
    t.string "external_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ledger_entries_on_account_id"
    t.index ["external_event_id"], name: "index_ledger_entries_on_external_event_id"
    t.index ["invoice_id"], name: "index_ledger_entries_on_invoice_id"
    t.index ["payment_event_id"], name: "index_ledger_entries_on_payment_event_id"
    t.check_constraint "amount_cents > 0", name: "ledger_entries_amount_cents_positive"
  end

  create_table "payment_events", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "invoice_id", null: false
    t.string "provider", null: false
    t.string "external_event_id", null: false
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_payment_events_on_account_id"
    t.index ["invoice_id"], name: "index_payment_events_on_invoice_id"
    t.index ["provider", "external_event_id"], name: "index_payment_events_on_provider_and_external_event_id"
  end

  add_foreign_key "customers", "accounts"
  add_foreign_key "documents", "accounts"
  add_foreign_key "documents", "invoices"
  add_foreign_key "extraction_runs", "accounts"
  add_foreign_key "extraction_runs", "documents"
  add_foreign_key "invoices", "accounts"
  add_foreign_key "invoices", "customers"
  add_foreign_key "ledger_entries", "accounts"
  add_foreign_key "ledger_entries", "invoices"
  add_foreign_key "ledger_entries", "payment_events"
  add_foreign_key "payment_events", "accounts"
  add_foreign_key "payment_events", "invoices"
end
