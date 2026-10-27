export function formatMoney(cents: number): string {
  const sign = cents < 0 ? "-" : "";
  const absolute = Math.abs(cents);
  const dollars = Math.floor(absolute / 100);
  const remainder = (absolute % 100).toString().padStart(2, "0");
  return `${sign}$${dollars}.${remainder}`;
}

export function formatWhen(value: string | null): string {
  if (!value) return "—";
  return value.slice(0, 16).replace("T", " ");
}
