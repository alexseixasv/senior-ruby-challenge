import { useQuery } from "@tanstack/react-query";
import { fetchDashboardSummary, fetchInvoices } from "../services/api";
import { useAccount } from "../context/AccountContext";

export function useDashboardSummary() {
  const { accountId } = useAccount();
  return useQuery({
    queryKey: ["dashboard-summary", accountId],
    queryFn: () => fetchDashboardSummary(accountId)
  });
}

export function useInvoices() {
  const { accountId } = useAccount();
  return useQuery({
    queryKey: ["invoices", accountId],
    queryFn: () => fetchInvoices(accountId)
  });
}
