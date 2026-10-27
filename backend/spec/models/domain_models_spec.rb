require "rails_helper"

RSpec.describe "domain models" do
  it "creates an account with customers and invoices" do
    account = create(:account, name: "Northwind Logistics")
    customer = create(:customer, account: account, email: "ap@example.com")
    invoice = create(:invoice, account: account, customer: customer, invoice_number: "INV-42", amount_cents: 12_00)

    expect(invoice.customer).to eq(customer)
    expect(account.invoices).to contain_exactly(invoice)
  end

  it "rejects a non-positive invoice amount" do
    invoice = build(:invoice, amount_cents: 0)

    expect(invoice).not_to be_valid
    expect(invoice.errors[:amount_cents]).to be_present
  end

  it "keeps invoice numbers unique inside an account and reusable across accounts" do
    first = create(:invoice, invoice_number: "INV-SHARED")
    duplicate = build(:invoice, account: first.account, customer: first.customer, invoice_number: "INV-SHARED")
    other_account = create(:account)

    expect(duplicate).not_to be_valid
    expect(build(:invoice, account: other_account, invoice_number: "INV-SHARED")).to be_valid
  end

  it "rejects a customer from another account" do
    account = create(:account)
    invoice = build(:invoice, account: account, customer: create(:customer))

    expect(invoice).not_to be_valid
    expect(invoice.errors[:customer]).to include("must belong to the same account")
  end

  it "rejects an unknown invoice status" do
    expect(build(:invoice, status: "void")).not_to be_valid
  end
end
