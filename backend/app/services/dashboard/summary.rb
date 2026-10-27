module Dashboard
  class Summary
    def initialize(account)
      @account = account
    end

    def as_json
      counts = @account.invoices.group(:status).count
      {
        total: counts.values.sum,
        pending: counts.fetch("pending", 0),
        processing: counts.fetch("processing", 0),
        processed: counts.fetch("processed", 0),
        failed: counts.fetch("failed", 0)
      }
    end
  end
end
