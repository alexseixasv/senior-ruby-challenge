import type { Invoice, VisibleInvoice } from "../types/invoice";

export const filterDiagnostics = {
  comparisons: 0,
  computations: 0
};

export function resetFilterDiagnostics(): void {
  filterDiagnostics.comparisons = 0;
  filterDiagnostics.computations = 0;
}

export function selectVisibleInvoices(invoices: Invoice[], status: string): VisibleInvoice[] {
  filterDiagnostics.computations += 1;

  return invoices
    .map((invoice) => {
      filterDiagnostics.comparisons += 1;
      let clusterSize = 0;
      for (const other of invoices) {
        filterDiagnostics.comparisons += 1;
        if (other.customer_name === invoice.customer_name && other.status === invoice.status) {
          clusterSize += 1;
        }
      }
      return { ...invoice, clusterSize };
    })
    .filter((invoice) => status === "all" || invoice.status === status);
}
