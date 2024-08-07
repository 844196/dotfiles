import $ from "https://deno.land/x/dax@0.28.0/mod.ts";
import { Table } from "https://deno.land/x/cliffy@v1.0.0-rc.3/table/mod.ts";
import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.3/ansi/colors.ts";
import { parseFlags } from "https://deno.land/x/cliffy@v1.0.0-rc.3/flags/mod.ts";
import { emojify } from "https://deno.land/x/github_emoji@v0.1.1/mod.ts";

type Row = [
  name: string,
  sha: string,
  subject: string,
  isHead: "true" | "false",
  upstream: string,
];

const branches =
  await $`git branch --format='%(refname:short)\t%(objectname:short)\t%(subject)\t%(if)%(HEAD)%(then)true%(else)false%(end)\t%(upstream:track)'`
    .lines()
    .then((xs) => xs.map((x) => x.split("\t") as Row))
    .then((xs) =>
      xs.map(([name, sha, subject, isHead, upstream]) => ({
        name,
        sha,
        subject,
        isHead: isHead === "true",
        isTopic: name.includes("/"),
        isGone: upstream === "[gone]",
        upstream,
      }))
    );

const { flags } = parseFlags(Deno.args, {
  flags: [
    {
      name: "head-ignore",
    },
    {
      name: "gone-first",
    },
  ],
});

const rows = branches
  .filter(({ isHead }) => {
    if (isHead === false) {
      return true;
    }
    return flags["headIgnore"] === true ? false : true;
  })
  .sort((left, right) => {
    if (left.isHead && right.isHead === false) return 1;
    if (left.isHead === false && right.isHead) return -1;

    if (flags["goneFirst"] === true) {
      if (left.isGone && right.isGone === false) return -1;
      if (left.isGone === false && right.isGone) return 1;
    } else {
      if (left.isGone && right.isGone === false) return 1;
      if (left.isGone === false && right.isGone) return -1;
    }

    if (left.isTopic && right.isTopic === false) return 1;
    if (left.isTopic === false && right.isTopic) return -1;

    return left.name.localeCompare(right.name);
  })
  .map((branch) => {
    let name: string;
    if (branch.isHead) {
      name = colors.bold.green(branch.name);
    } else if (branch.isGone) {
      name = colors.bold.red.strikethrough.reset(branch.name);
    } else {
      name = branch.name;
    }

    const sha = colors.bold.black(branch.sha);
    const desc = colors.bold.black(
      `${emojify(branch.subject)} ${branch.upstream}`,
    );

    return [name, colors.brightBlack.dim("│"), sha, desc];
  });

if (rows.length === 0) {
  Deno.exit(0);
}

Table.from(rows).render();
