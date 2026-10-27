import type { ReactNode } from "react";
import { Link } from "react-router-dom";
import { DEMO_ACCOUNTS, useAccount } from "../context/AccountContext";

export function Layout({ children }: { children: ReactNode }) {
  const { accountId, setAccountId } = useAccount();

  return (
    <div className="app-shell">
      <header className="topbar">
        <div>
          <Link to="/" className="brand">
            FlowOps
          </Link>
          <p className="brand-subtitle">Invoice operations</p>
        </div>
        <label className="account-switcher">
          Account
          <select
            aria-label="Account"
            value={accountId}
            onChange={(event) => setAccountId(Number(event.target.value))}
          >
            {DEMO_ACCOUNTS.map((account) => (
              <option key={account.id} value={account.id}>
                {account.name}
              </option>
            ))}
          </select>
        </label>
      </header>
      <main>{children}</main>
    </div>
  );
}
