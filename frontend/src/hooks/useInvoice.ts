import { useQuery } from "@tanstack/react-query";
import { fetchInvoice } from "../services/api";
import { useAccount } from "../context/AccountContext";

export function useInvoice(invoiceId: number, watching: boolean) {
  const { accountId } = useAccount();
  return useQuery({
    queryKey: ["invoice", accountId, invoiceId],
    queryFn: () => fetchInvoice(accountId, invoiceId),
    enabled: Number.isFinite(invoiceId),
    refetchInterval: watching ? 1000 : false
  });
}
