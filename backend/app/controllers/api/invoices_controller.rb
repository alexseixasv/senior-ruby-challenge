module Api
  class InvoicesController < BaseController
    def index
      filters = params.permit(:status, :customer_id, :page, :per_page)
      relation = Invoices::Query.new(current_account).relation(filters)
      page = page_number(filters[:page])
      per_page = page_size(filters[:per_page])
      total = relation.count
      invoices = relation.offset((page - 1) * per_page).limit(per_page)

      render json: {
        invoices: invoices.map { |invoice| InvoiceSerializer.new(invoice).as_json },
        meta: { page: page, per_page: per_page, total: total }
      }
    end

    def show
      invoice = Invoice.includes(:customer, :documents).find(params[:id])
      render json: InvoiceSerializer.new(invoice, include_details: true).as_json
    end

    def create
      customer = current_account.customers.find(invoice_params[:customer_id])
      invoice = current_account.invoices.new(invoice_params.merge(customer: customer, status: "pending"))

      if invoice.save
        render json: InvoiceSerializer.new(invoice).as_json, status: :created
      else
        render json: { error: "validation_failed", details: invoice.errors.full_messages }, status: :unprocessable_content
      end
    rescue ActiveRecord::RecordNotUnique
      render json: { error: "validation_failed", details: ["Invoice number has already been taken"] }, status: :unprocessable_content
    end

    def update
      invoice = current_account.invoices.find(params[:id])

      if invoice.update(update_params)
        render json: InvoiceSerializer.new(invoice).as_json
      else
        render json: { error: "validation_failed", details: invoice.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    def invoice_params
      params.permit(:customer_id, :invoice_number, :amount_cents, :description)
    end

    def update_params
      params.permit(:description, :status)
    end

    def page_number(value)
      number = value.to_i
      number.positive? ? number : 1
    end

    def page_size(value)
      number = value.to_i
      number = 25 if number <= 0
      [number, 100].min
    end
  end
end
