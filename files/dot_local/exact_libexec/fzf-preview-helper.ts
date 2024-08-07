import $ from "https://deno.land/x/dax@0.39.0/mod.ts";
import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";

const COLUMNS = Deno.env.get("FZF_PREVIEW_COLUMNS");
const LINES = Deno.env.get("FZF_PREVIEW_LINES");

await new Command()
  .command("git-status")
  .arguments("<line:string>")
  .action(async (_, line) => {
    if (line.length === 0) {
      return;
    }

    const [symbol, path] = line.split(" │ ");
    const [filename, newFileName] = path.split(" -> ");

    if (newFileName !== undefined) {
      await $`git diff HEAD:${filename} ${newFileName}`
        .pipe($`delta --width ${COLUMNS}`);
      return;
    }

    if (symbol === "??") {
      await $`delta --width ${COLUMNS} /dev/null ${filename} || true`;
      return;
    }

    if (/^.\S/.test(symbol)) {
      await $`git diff -- ${filename}`
        .pipe($`delta --width ${COLUMNS}`);
    } else {
      await $`git diff --cached -- ${filename}`
        .pipe($`delta --width ${COLUMNS}`);
    }
  })
  .command("git-branch")
  .arguments("<branch:string>")
  .action(async (_, branch) => {
    await $`git --no-pager graph -n ${Math.ceil(Number(LINES) / 2)} ${branch}`
      .pipe($`emojify`);
  })
  .parse();
