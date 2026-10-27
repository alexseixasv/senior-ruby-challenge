import { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { StatusBadge } from "../components/StatusBadge";
import { useAccount } from "../context/AccountContext";
import { useInvoice } from "../hooks/useInvoice";
import { processDocument } from "../services/api";
import { formatMoney, formatWhen } from "../services/money";

export function InvoiceDetailPage() {
  const params = useParams();
  const invoiceId = Number(params.invoiceId);
  const { accountId } = useAccount();
  const queryClient = useQueryClient();
  const [watching, setWatching] = useState(false);
  const invoice = useInvoice(invoiceId, watching);

  const process = useMutation({
    mutationFn: (documentId: number) => processDocument(accountId, documentId),
    onSuccess: async () => {
      setWatching(true);
      await queryClient.invalidateQueries({ queryKey: ["invoice", accountId, invoiceId] });
    }
  });

  if (invoice.isLoading) return <p>Loading invoice…</p>;
  if (invoice.isError) return <p className="banner">Invoice could not be loaded.</p>;
  if (!invoice.data) return null;

  const record = invoice.data;

  return (
    <section className="page">
      <Link to="/" className="back-link">
        Back to invoices
      </Link>
      <div className="page-heading">
        <h1>{record.invoice_number}</h1>
        <p>
          {record.customer_name} · {formatMoney(record.amount_cents)} · applied {formatMoney(record.applied_cents)}
        </p>
      </div>
      <p>
        <StatusBadge status={record.status} /> <span className="muted">Updated {formatWhen(record.updated_at)}</span>
      </p>
      <p>{record.description || "No description"}</p>

      <h2>Documents</h2>
      {record.documents.length === 0 ? <p className="empty-state">No documents attached.</p> : null}
      <ul className="document-list">
        {record.documents.map((document) => (
          <li key={document.id}>
            <div>
              <strong>{document.filename}</strong>
              <StatusBadge status={document.status} />
            </div>
            {document.extracted_data ? (
              <pre>{JSON.stringify(document.extracted_data, null, 2)}</pre>
            ) : (
              <p className="muted">No extraction stored.</p>
            )}
            <button
              type="button"
              onClick={() => process.mutate(document.id)}
              disabled={document.status === "processed" || process.isPending}
            >
              Process document
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
}
