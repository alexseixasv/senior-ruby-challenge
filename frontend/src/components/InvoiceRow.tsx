import { recordRowRender } from "../diagnostics/renderProbe";
import { formatMoney } from "../services/money";
import type { VisibleInvoice } from "../types/invoice";
import { StatusBadge } from "./StatusBadge";
import { Link } from "react-router-dom";

interface InvoiceRowProps {
  invoice: VisibleInvoice;
  selected: boolean;
  onSelect: (invoiceId: number) => void;
  tone: { color: string };
}

export function InvoiceRow({ invoice, selected, onSelect, tone }: InvoiceRowProps) {
  recordRowRender(invoice.id);

  return (
    <tr
      data-testid={`invoice-row-${invoice.id}`}
      data-cluster-size={invoice.clusterSize}
      className={selected ? "is-selected" : undefined}
      style={{ boxShadow: `inset 3px 0 0 ${tone.color}` }}
    >
      <td>
        <Link to={`/invoices/${invoice.id}`}>{invoice.invoice_number}</Link>
      </td>
      <td>{invoice.customer_name}</td>
      <td>{formatMoney(invoice.amount_cents)}</td>
      <td>
        <StatusBadge status={invoice.status} />
      </td>
      <td>
        <button type="button" onClick={() => onSelect(invoice.id)}>
          {selected ? "Selected" : `Select ${invoice.invoice_number}`}
        </button>
      </td>
    </tr>
  );
}
