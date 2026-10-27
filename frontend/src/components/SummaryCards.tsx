import type { DashboardSummary } from "../types/invoice";

const CARDS: Array<{ key: keyof DashboardSummary; label: string }> = [
  { key: "total", label: "Total" },
  { key: "pending", label: "Pending" },
  { key: "processing", label: "Processing" },
  { key: "processed", label: "Processed" },
  { key: "failed", label: "Failed" }
];

export function SummaryCards({ summary }: { summary: DashboardSummary | undefined }) {
  return (
    <section className="summary-grid" aria-label="Invoice summary">
      {CARDS.map((card) => (
        <article key={card.key} className="summary-card" data-testid={`summary-${card.key}`}>
          <h2>{card.label}</h2>
          <p>{summary ? summary[card.key] : "—"}</p>
        </article>
      ))}
    </section>
  );
}
