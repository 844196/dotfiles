import { border as defaultBorder, Table } from "https://deno.land/x/cliffy@v1.0.0-rc.3/table/mod.ts";
import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.3/ansi/colors.ts";

type Gitmojis = {
  gitmojis: {
    emoji: string; // 👍
    code: string; // :+1:
    description: string;
  }[];
};

const json = await fetch(
  new URL(
    `${Deno.env.get("HOME")}/.cache/gitmoji/gitmojis.json`,
    import.meta.url,
  ),
).then<Gitmojis>((x) => x.json());

const rows = json.gitmojis.map(({ emoji, code, description }) => [
  emoji,
  colors.bold.black(code),
  colors.bold.black(description),
]);

const plainBorder = Object.entries(defaultBorder)
  .reduce<Record<string, string>>(
    (acc, [k]) => {
      acc[k] = "";
      return acc;
    },
    {},
  );

Table.from(rows)
  .border(true).chars({ ...plainBorder, middle: colors.brightBlack.dim("│") })
  .render();
