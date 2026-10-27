module Invoices
  class Query
    def initialize(account)
      @account = account
    end

    def relation(filters = {})
      scope = @account.invoices.order(created_at: :desc, id: :desc)
      scope = scope.where(status: filters[:status]) if filters[:status].present?
      scope = scope.where(customer_id: filters[:customer_id]) if filters[:customer_id].present?
      scope
    end
  end
end
