export type InvoiceStatus = "pending" | "processing" | "processed" | "failed";
export type DocumentStatus = InvoiceStatus;

export interface Invoice {
  id: number;
  account_id: number;
  customer_id: number;
  customer_name: string;
  invoice_number: string;
  amount_cents: number;
  status: InvoiceStatus;
  description: string | null;
  processed_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface VisibleInvoice extends Invoice {
  clusterSize: number;
}

export interface InvoiceDocument {
  id: number;
  account_id: number;
  invoice_id: number;
  filename: string;
  status: DocumentStatus;
  extracted_data: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
}

export interface InvoiceDetails extends Invoice {
  applied_cents: number;
  documents: InvoiceDocument[];
}

export interface InvoiceListResponse {
  invoices: Invoice[];
  meta: {
    page: number;
    per_page: number;
    total: number;
  };
}

export interface DashboardSummary {
  total: number;
  pending: number;
  processing: number;
  processed: number;
  failed: number;
}
