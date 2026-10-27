const RENDER_PROBE = Symbol.for("flowops.invoiceRowRenders");

type ProbeHost = typeof globalThis & {
  [RENDER_PROBE]?: Map<number, number>;
};

export function installRowRenderProbe(): Map<number, number> {
  const counts = new Map<number, number>();
  (globalThis as ProbeHost)[RENDER_PROBE] = counts;
  return counts;
}

export function clearRowRenderProbe(): void {
  delete (globalThis as ProbeHost)[RENDER_PROBE];
}

export function recordRowRender(invoiceId: number): void {
  const counts = (globalThis as ProbeHost)[RENDER_PROBE];
  if (!counts) return;
  counts.set(invoiceId, (counts.get(invoiceId) ?? 0) + 1);
}
