import $ from "https://deno.land/x/dax@0.28.0/mod.ts";
import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.3/ansi/colors.ts";

const statuses = await $`git add -n -A`.lines();
if (statuses.join("").trim() === "") {
  console.log("No changes to stage.");
  Deno.exit(0);
}

const lines = statuses.sort((a, b) => a.localeCompare(b))
  .map((str) =>
    str
      .replace(/^add '/, "add ")
      .replace(/^remove '/, "remove ")
      .replace(/'$/, "")
      .replace(/^add/, colors.green("add"))
      .replace(/^remove/, colors.red("remove"))
  );

console.log("");
console.log(colors.black("┃"));
console.log(`${colors.black("┃")}  ${colors.brightBlack("The following changes will be staged:")}`);
console.log(colors.black("┃"));
for (const line of lines) {
  console.log(`${colors.black("┃")}    ${colors.brightBlack("•")} ${line}`);
}
console.log(colors.black("┃"));
console.log("");

const response = await $.confirm(`${colors.yellow("Confirm?")}`, {
  default: true,
  noClear: true,
});

if (response) {
  await $`git add -A`;
} else {
  console.error("Aborted.");
  Deno.exit(1);
}
