import type { DashboardSummary, InvoiceDetails, InvoiceDocument, InvoiceListResponse } from "../types/invoice";

const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:3000";

export function demoToken(accountId: number): string {
  return `demo-account-${accountId}`;
}

async function request<T>(path: string, accountId: number, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_URL}${path}`, {
    ...init,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      Authorization: `Bearer ${demoToken(accountId)}`,
      ...(init?.headers ?? {})
    }
  });

  if (!response.ok) {
    let message = `request_failed_${response.status}`;
    try {
      const body = (await response.json()) as { error?: string };
      if (body.error) message = body.error;
    } catch {
      message = `request_failed_${response.status}`;
    }
    throw new Error(message);
  }

  return (await response.json()) as T;
}

export function fetchDashboardSummary(accountId: number): Promise<DashboardSummary> {
  return request<DashboardSummary>("/api/dashboard/summary", accountId);
}

export function fetchInvoices(accountId: number): Promise<InvoiceListResponse> {
  return request<InvoiceListResponse>("/api/invoices?per_page=50", accountId);
}

export function fetchInvoice(accountId: number, invoiceId: number): Promise<InvoiceDetails> {
  return request<InvoiceDetails>(`/api/invoices/${invoiceId}`, accountId);
}

export function processDocument(accountId: number, documentId: number): Promise<InvoiceDocument> {
  return request<InvoiceDocument>(`/api/documents/${documentId}/process`, accountId, { method: "POST" });
}
