import { colors, match, SimpleGit } from "../deps.ts";

const colorizeSymbol = ($: string) =>
  match($)
    .with(" ", () => () => " ")
    .with("?", () => colors.green)
    .with("M", () => colors.cyan)
    .with("R", () => colors.magenta)
    .with("D", () => colors.red)
    .otherwise(() => colors.yellow)($);

export async function status(git: SimpleGit) {
  const { files } = await git.status();

  return files
    .map(({ path, index, working_dir }) =>
      [
        `${colorizeSymbol(index)}${colorizeSymbol(working_dir)}`,
        colors.rgb24("\u2502", 0x34394e),
        colors.white(path),
      ].join(" ")
    )
    .join("\n");
}
