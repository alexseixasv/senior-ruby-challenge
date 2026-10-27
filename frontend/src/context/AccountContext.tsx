import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

export const DEMO_ACCOUNTS = [
  { id: 1, name: "Northwind Logistics" },
  { id: 2, name: "Brightline Health" },
  { id: 3, name: "Cedar & Co." }
] as const;

const STORAGE_KEY = "flowops.accountId";

interface AccountContextValue {
  accountId: number;
  accountName: string;
  setAccountId: (accountId: number) => void;
}

const AccountContext = createContext<AccountContextValue | null>(null);

function readInitialAccount(initialAccountId?: number): number {
  if (initialAccountId) return initialAccountId;
  const stored = window.localStorage.getItem(STORAGE_KEY);
  const parsed = stored ? Number(stored) : 1;
  return DEMO_ACCOUNTS.some((account) => account.id === parsed) ? parsed : 1;
}

export function AccountProvider({
  children,
  initialAccountId
}: {
  children: ReactNode;
  initialAccountId?: number;
}) {
  const [accountId, setAccountIdState] = useState(() => readInitialAccount(initialAccountId));

  const value = useMemo<AccountContextValue>(() => {
    const account = DEMO_ACCOUNTS.find((item) => item.id === accountId) ?? DEMO_ACCOUNTS[0];
    return {
      accountId: account.id,
      accountName: account.name,
      setAccountId: (nextId: number) => {
        window.localStorage.setItem(STORAGE_KEY, String(nextId));
        setAccountIdState(nextId);
      }
    };
  }, [accountId]);

  return <AccountContext.Provider value={value}>{children}</AccountContext.Provider>;
}

export function useAccount(): AccountContextValue {
  const value = useContext(AccountContext);
  if (!value) throw new Error("useAccount must be used within AccountProvider");
  return value;
}
