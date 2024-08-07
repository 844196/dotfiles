import $ from "https://deno.land/x/dax@0.28.0/mod.ts";
import { relative } from "https://deno.land/std@0.224.0/path/mod.ts";
import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.3/ansi/colors.ts";

function colorizeSymbol(x: string) {
  switch (x) {
    case " ":
      return " ";
    case "?":
      return colors.green(x);
    case "M":
      return colors.cyan(x);
    case "R":
      return colors.magenta(x);
    case "D":
      return colors.red(x);
    default:
      return colors.yellow(x);
  }
}

const cwd = Deno.cwd();
const repoRoot = await $`git rev-parse --show-toplevel`.text();

const statuses = [];
for (const l of await $`git status --porcelain -uall`.lines()) {
  const [index, workingDir, path] = l
    .replace(/^(.)(.) /, "$1\0$2\0")
    .split("\0");

  if (path === undefined) {
    continue;
  }

  statuses.push([
    colorizeSymbol(index),
    colorizeSymbol(workingDir),
    colors.brightBlack.dim(" │ "),
    relative(cwd, `${repoRoot}/${path}`),
  ].join(""));
}

if (statuses.length === 0) {
  Deno.exit(0);
}

console.log(statuses.join("\n"));
