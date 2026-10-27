import type { InvoiceStatus, VisibleInvoice } from "../types/invoice";
import { InvoiceRow } from "./InvoiceRow";

const TONES: Record<InvoiceStatus, string> = {
  pending: "#9a6700",
  processing: "#1d4e89",
  processed: "#1f7a4d",
  failed: "#a12622"
};

export function InvoiceTable({
  invoices,
  selectedId,
  onSelect
}: {
  invoices: VisibleInvoice[];
  selectedId: number | null;
  onSelect: (invoiceId: number) => void;
}) {
  if (invoices.length === 0) {
    return <p className="empty-state">No invoices match this filter.</p>;
  }

  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th scope="col">Invoice</th>
            <th scope="col">Customer</th>
            <th scope="col">Amount</th>
            <th scope="col">Status</th>
            <th scope="col">Selection</th>
          </tr>
        </thead>
        <tbody>
          {invoices.map((invoice) => (
            <InvoiceRow
              key={invoice.id}
              invoice={invoice}
              selected={invoice.id === selectedId}
              onSelect={() => onSelect(invoice.id)}
              tone={{ color: TONES[invoice.status] }}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}
