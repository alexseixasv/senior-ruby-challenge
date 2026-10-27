module TableCleaner
  def clear_flowops_tables
    ExtractionRun.delete_all
    LedgerEntry.delete_all
    PaymentEvent.delete_all
    Document.delete_all
    Invoice.delete_all
    Customer.delete_all
    Account.delete_all
  end
end
