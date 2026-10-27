import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useState, type ReactNode } from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { AccountProvider } from "./context/AccountContext";
import { DashboardPage } from "./pages/DashboardPage";
import { InvoiceDetailPage } from "./pages/InvoiceDetailPage";

export function App() {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            refetchOnWindowFocus: false,
            retry: 1
          }
        }
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <AccountProvider>
        <AppRoutes />
      </AccountProvider>
    </QueryClientProvider>
  );
}

export function AppRoutes() {
  return (
    <BrowserRouter>
      <Layout>
        <Routes>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/invoices/:invoiceId" element={<InvoiceDetailPage />} />
        </Routes>
      </Layout>
    </BrowserRouter>
  );
}

export function TestProviders({ children }: { children: ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: { queries: { retry: false } }
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <AccountProvider initialAccountId={1}>{children}</AccountProvider>
    </QueryClientProvider>
  );
}
