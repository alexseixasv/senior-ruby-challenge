import type { InvoiceStatus } from "../types/invoice";

export function StatusBadge({ status }: { status: InvoiceStatus | string }) {
  return <span className={`status status-${status}`}>{status}</span>;
}
