import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { TestProviders } from "../App";
import { clearRowRenderProbe, installRowRenderProbe } from "../diagnostics/renderProbe";
import { DashboardPage } from "../pages/DashboardPage";
import { fetchDashboardSummary, fetchInvoices } from "../services/api";
import { filterDiagnostics, resetFilterDiagnostics, selectVisibleInvoices } from "../services/invoiceFilters";
import type { Invoice, InvoiceStatus } from "../types/invoice";

vi.mock("../services/api", () => ({
  fetchDashboardSummary: vi.fn(),
  fetchInvoices: vi.fn(),
  fetchInvoice: vi.fn(),
  processDocument: vi.fn(),
  demoToken: (accountId: number) => `demo-account-${accountId}`
}));

function sampleInvoice(id: number, status: InvoiceStatus): Invoice {
  return {
    id,
    account_id: 1,
    customer_id: id,
    customer_name: `Customer ${id}`,
    invoice_number: `INV-${1000 + id}`,
    amount_cents: 15_000,
    status,
    description: "Monthly services",
    processed_at: null,
    created_at: "2026-01-05T15:00:00Z",
    updated_at: "2026-01-05T15:00:00Z"
  };
}

const PAGE = [
  sampleInvoice(101, "pending"),
  sampleInvoice(102, "failed"),
  sampleInvoice(103, "processed")
];

function renderDashboard() {
  return render(
    <TestProviders>
      <MemoryRouter>
        <DashboardPage />
      </MemoryRouter>
    </TestProviders>
  );
}

describe("invoice dashboard performance", () => {
  beforeEach(() => {
    resetFilterDiagnostics();
    clearRowRenderProbe();
    vi.mocked(fetchDashboardSummary).mockResolvedValue({
      total: 3,
      pending: 1,
      processing: 0,
      processed: 1,
      failed: 1
    });
    vi.mocked(fetchInvoices).mockResolvedValue({
      invoices: PAGE,
      meta: { page: 1, per_page: 50, total: 3 }
    });
  });

  it("filters invoices with work proportional to the page size", () => {
    const invoices = Array.from({ length: 24 }, (_, index) => sampleInvoice(index + 1, index % 2 === 0 ? "pending" : "processed"));
    resetFilterDiagnostics();

    const visible = selectVisibleInvoices(invoices, "pending");

    expect(visible.map((invoice) => invoice.id)).toEqual(invoices.filter((invoice) => invoice.status === "pending").map((invoice) => invoice.id));
    expect(filterDiagnostics.comparisons).toBeLessThanOrEqual(invoices.length);
  });

  it("does not rebuild the visible invoice list when the selected row changes", async () => {
    renderDashboard();
    await screen.findByText("INV-1101");
    const computations = filterDiagnostics.computations;
    expect(computations).toBeGreaterThan(0);

    fireEvent.click(screen.getByRole("button", { name: "Select INV-1101" }));

    expect(filterDiagnostics.computations).toBe(computations);
  });

  it("does not rerender unrelated invoice rows when the selection changes", async () => {
    const renders = installRowRenderProbe();
    renderDashboard();
    await screen.findByText("INV-1102");
    const unrelatedRenders = renders.get(102);
    expect(unrelatedRenders).toBeGreaterThan(0);

    fireEvent.click(screen.getByRole("button", { name: "Select INV-1101" }));

    expect(renders.get(102)).toBe(unrelatedRenders);
  });
});
