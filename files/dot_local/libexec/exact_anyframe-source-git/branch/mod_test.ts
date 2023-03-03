import { assertEquals } from "../dev_deps.ts";
import { compareBranch, makeUpstreamLabel } from "./mod.ts";
import { Branch, branchSchema, Diverged } from "./branch.ts";

Deno.test("compareBranch", () => {
  const branch = (
    name: string,
    opts?: Partial<Pick<Branch, "isCurrent" | "diverged">>,
  ) =>
    branchSchema.parse(
      {
        name,
        headSubject: "example",
        isCurrent: opts?.isCurrent ?? false,
        diverged: opts?.diverged ?? { ahead: 0, behind: 0 },
      } satisfies Branch,
    );

  const actual = [
    branch("wip", { diverged: "GONE" }),
    branch("production"),
    branch("john-doe/fix-zzz", { diverged: "GONE" }),
    branch("844196/feat-abc", { diverged: "GONE" }),
    branch("main", { isCurrent: true }),
    branch("844196/feat-xyz"),
    branch("development"),
    branch("844196/feat-def"),
  ].toSorted(compareBranch);

  const expected = [
    branch("main", { isCurrent: true }),
    branch("development"),
    branch("production"),
    branch("844196/feat-def"),
    branch("844196/feat-xyz"),
    branch("wip", { diverged: "GONE" }),
    branch("844196/feat-abc", { diverged: "GONE" }),
    branch("john-doe/fix-zzz", { diverged: "GONE" }),
  ];

  assertEquals(actual, expected);
});

Deno.test("aheadBehindLabel", () => {
  const matrix: [Diverged, string][] = [
    ["GONE", ""],
    [{ ahead: 0, behind: 0 }, ""],
    [{ ahead: 1, behind: 0 }, "⇡1"],
    [{ ahead: 0, behind: 2 }, "⇣2"],
    [{ ahead: 1, behind: 2 }, "⇡1 ⇣2"],
  ];

  for (const [diverged, expected] of matrix) {
    const actual = makeUpstreamLabel(diverged);
    assertEquals(actual, expected);
  }
});
