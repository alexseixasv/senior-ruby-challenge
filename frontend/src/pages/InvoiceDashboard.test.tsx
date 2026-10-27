import { fireEvent, render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { TestProviders } from "../App";
import { DashboardPage } from "../pages/DashboardPage";
import { fetchDashboardSummary, fetchInvoices } from "../services/api";
import type { Invoice } from "../types/invoice";

vi.mock("../services/api", () => ({
  fetchDashboardSummary: vi.fn(),
  fetchInvoices: vi.fn(),
  fetchInvoice: vi.fn(),
  processDocument: vi.fn(),
  demoToken: (accountId: number) => `demo-account-${accountId}`
}));

function sampleInvoice(overrides: Pick<Invoice, "id" | "customer_name" | "invoice_number" | "status">): Invoice {
  return {
    account_id: 1,
    customer_id: overrides.id,
    amount_cents: 15_000,
    description: "Monthly services",
    processed_at: null,
    created_at: "2026-01-05T15:00:00Z",
    updated_at: "2026-01-05T15:00:00Z",
    ...overrides
  };
}

function renderDashboard() {
  return render(
    <TestProviders>
      <MemoryRouter>
        <DashboardPage />
      </MemoryRouter>
    </TestProviders>
  );
}

describe("invoice dashboard", () => {
  beforeEach(() => {
    vi.mocked(fetchDashboardSummary).mockResolvedValue({
      total: 3,
      pending: 1,
      processing: 0,
      processed: 1,
      failed: 1
    });
    vi.mocked(fetchInvoices).mockResolvedValue({
      invoices: [
        sampleInvoice({ id: 1, customer_name: "Harbor Freight Co", invoice_number: "INV-1001", status: "pending" }),
        sampleInvoice({ id: 2, customer_name: "Lumen Clinic", invoice_number: "INV-1002", status: "failed" }),
        sampleInvoice({ id: 3, customer_name: "Pine Street Goods", invoice_number: "INV-1003", status: "processed" })
      ],
      meta: { page: 1, per_page: 50, total: 3 }
    });
  });

  it("renders summary counts, customer, amount, and status", async () => {
    renderDashboard();

    expect(await screen.findByText("INV-1001")).toBeInTheDocument();
    expect(screen.getByTestId("summary-total")).toHaveTextContent("3");
    expect(screen.getByTestId("summary-pending")).toHaveTextContent("1");
    expect(screen.getByTestId("summary-processed")).toHaveTextContent("1");
    expect(screen.getByTestId("summary-failed")).toHaveTextContent("1");
    expect(screen.getByText("Harbor Freight Co")).toBeInTheDocument();
    expect(screen.getAllByText("$150.00").length).toBeGreaterThan(0);
    expect(screen.getAllByText("pending").length).toBeGreaterThan(0);
  });

  it("filters the table by status", async () => {
    renderDashboard();
    await screen.findByText("INV-1001");

    fireEvent.change(screen.getByLabelText("Status"), { target: { value: "failed" } });

    expect(screen.queryByText("INV-1001")).not.toBeInTheDocument();
    expect(screen.getByText("INV-1002")).toBeInTheDocument();
    expect(screen.getByText("Lumen Clinic")).toBeInTheDocument();
  });
});
