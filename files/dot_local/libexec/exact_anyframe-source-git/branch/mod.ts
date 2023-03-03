import { colors, IRow, match, P, type SimpleGit, Table } from "../deps.ts";
import {
  Branch,
  Diverged,
  fromSimpleGitBranch,
  isGone,
  isTopicBranch,
} from "./branch.ts";
import { compareBool, concatComparator } from "./comparison.ts";

export const compareBranch = concatComparator<Branch>(
  (a, b) => compareBool(a.isCurrent, b.isCurrent) * -1, // desc
  (a, b) => compareBool(isGone(a), isGone(b)),
  (a, b) => compareBool(isTopicBranch(a), isTopicBranch(b)),
  (a, b) => a.name.localeCompare(b.name),
);

export const makeUpstreamLabel = (diverged: Diverged): string => {
  if (diverged === "GONE") return "";

  const { ahead, behind } = diverged;
  return [
    ahead > 0 ? `⇡${ahead}` : "",
    behind > 0 ? `⇣${behind}` : "",
  ].join(" ").trim();
};

// colors.xxx() に空文字を渡すとstringではなくFunctionが返ってくることを回避する
const grayOrEmpty = (x: string) => x === "" ? "" : colors.gray(x);

export function toRow(branch: Branch): IRow {
  const branchName = match(branch)
    .with(P.when(isGone), () => colors.red.strikethrough.reset)
    .with({ isCurrent: true }, () => colors.green)
    .otherwise(() => colors.white)(branch.name);

  const upstream = grayOrEmpty(makeUpstreamLabel(branch.diverged) ?? "");

  return [
    [branchName, upstream].join(" ").trimEnd(),
    colors.gray(branch.headSubject),
  ];
}

export async function branch(git: SimpleGit) {
  const summary = await git.branchLocal();

  const rows = Object.values(summary.branches)
    .map(fromSimpleGitBranch)
    .toSorted(compareBranch)
    .map(toRow);

  return Table.from(rows).toString();
}
