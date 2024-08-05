import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/colors.ts";
import { tty } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/tty.ts";
import { KeyCode, parse } from "https://deno.land/x/cliffy@v1.0.0-rc.4/keycode/mod.ts";
import { border as defaultBorder, Table } from "https://deno.land/x/cliffy@v1.0.0-rc.4/table/mod.ts";
import { parse as parseYaml } from "jsr:@std/yaml";

async function* keypress(): AsyncGenerator<KeyCode, void> {
  while (true) {
    const data = new Uint8Array(8);

    Deno.stdin.setRaw(true);
    const nread = await Deno.stdin.read(data);
    Deno.stdin.setRaw(false);

    if (nread === null) {
      return;
    }

    const keys: Array<KeyCode> = parse(data.subarray(0, nread));

    for (const key of keys) {
      yield key;
    }
  }
}

type Binding =
  & {
    key: string;
    name: string;
    icon?: string;
  }
  & ({
    type: "command";
    command: string;
    eval?: boolean;
    trigger?: "ACCEPT" | "COMPLETE";
  } | {
    type: "bindings";
    bindings: Binding[];
  });

let bindings = parseYaml(Deno.readTextFileSync(`${Deno.env.get("XDG_CONFIG_HOME")}/wk/config.yaml`)) as Binding[];

const myTty = tty({
  writer: Deno.stderr,
  reader: Deno.stdin,
});

const initCursorPos = myTty.getCursorPosition();

const plainBorder = Object.entries(defaultBorder)
  .reduce<Record<string, string>>(
    (acc, [k]) => {
      acc[k] = "";
      return acc;
    },
    {},
  );
function toTable(bindings: Binding[]) {
  return Table
    .from(
      bindings.map((key) => [
        colors.white(key.key === "SPC" ? "␣" : key.key),
        colors.brightBlack(`${key.icon ?? ""}${key.icon ? " " : ""}${key.type === "bindings" ? "+" : ""}${key.name}`),
      ]),
    )
    .border(true).chars({ ...plainBorder, middle: colors.brightBlack.dim("➜") });
}

let table = toTable(bindings);

myTty
  .cursorHide
  .eraseLine
  .text(`${colors.brightBlack("")} `).cursorSave
  .cursorNextLine
  .text(table.toString())
  .cursorRestore
  .cursorShow();

const inputs = [];
for await (const key of keypress()) {
  if (key.ctrl && key.name === "c") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  if (typeof key.name === "undefined") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  const inputKey = key.name.replace("space", "SPC");

  const match = bindings.find((b) => b.key === inputKey);
  if (!match) {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  if (match.type === "command") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.log(`${match.command}\t${Number(match.eval ?? false)}\t${match.trigger ?? ""}`);

    Deno.exit(0);
  }

  if (match.type === "bindings") {
    inputs.push(match.key);

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < table.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    myTty.cursorTo(initCursorPos.x, initCursorPos.y);

    bindings = match.bindings;
    table = toTable(bindings);

    const n = myTty
      .cursorHide
      .text(`${colors.brightBlack("")} ${inputs.join(colors.brightBlack(" » "))} `).cursorSave
      .cursorNextLine;

    for (const line of table.toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }

    n.cursorRestore.cursorShow();
  }
}
