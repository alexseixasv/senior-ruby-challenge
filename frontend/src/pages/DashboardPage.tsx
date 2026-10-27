import { useState } from "react";
import { SummaryCards } from "../components/SummaryCards";
import { InvoiceTable } from "../components/InvoiceTable";
import { useDashboardSummary, useInvoices } from "../hooks/useInvoices";
import { selectVisibleInvoices } from "../services/invoiceFilters";
import type { InvoiceStatus } from "../types/invoice";

const FILTERS = ["all", "pending", "processing", "processed", "failed"] as const;

export function DashboardPage() {
  const summary = useDashboardSummary();
  const invoices = useInvoices();
  const [status, setStatus] = useState<(typeof FILTERS)[number]>("all");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const visibleInvoices = selectVisibleInvoices(invoices.data?.invoices ?? [], status);

  return (
    <section className="page">
      <div className="page-heading">
        <h1>Invoices</h1>
        <p>Review open balances, processed payments, and failed collections.</p>
      </div>

      {summary.isError ? <p className="banner">Summary could not be loaded.</p> : null}
      <SummaryCards summary={summary.data} />

      <div className="toolbar">
        <label>
          Status
          <select
            aria-label="Status"
            value={status}
            onChange={(event) => setStatus(event.target.value as (typeof FILTERS)[number] | InvoiceStatus)}
          >
            {FILTERS.map((option) => (
              <option key={option} value={option}>
                {option}
              </option>
            ))}
          </select>
        </label>
        <span className="toolbar-meta">{visibleInvoices.length} shown</span>
      </div>

      {invoices.isLoading ? <p>Loading invoices…</p> : null}
      {invoices.isError ? <p className="banner">Invoices could not be loaded.</p> : null}
      {invoices.isSuccess ? (
        <InvoiceTable invoices={visibleInvoices} selectedId={selectedId} onSelect={setSelectedId} />
      ) : null}
    </section>
  );
}
