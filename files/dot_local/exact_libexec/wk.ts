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
    buffer: string;
    eval?: boolean;
    trigger?: "ACCEPT" | "COMPLETE";
  } | {
    type: "bindings";
    bindings: Binding[];
  });

const bindings = parseYaml(Deno.readTextFileSync(`${Deno.env.get("XDG_CONFIG_HOME")}/wk/config.yaml`)) as Binding[];

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

// zle -M などによってプロンプト下に出力が残っている可能性があるため、あらかじめ表示予定領域をクリアしておく
const o = myTty.cursorHide.eraseLine.cursorNextLine;
for (let i = 0; i < bindings.length; i++) {
  o.eraseLine.cursorNextLine();
}
myTty.cursorTo(initCursorPos.x, initCursorPos.y);

myTty
  .cursorHide
  .eraseLine
  .text(`${colors.brightBlack("")} `).cursorSave
  .cursorNextLine
  .text(toTable(bindings).toString())
  .cursorRestore
  .cursorShow();

const moveStack: [Binding[], ...(Binding[])[]] = [bindings];
const inputKeys = [];
for await (const key of keypress()) {
  if (typeof key.name === "undefined") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(128);
  }
  if (key.ctrl && key.name === "c") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }
  if (key.name === "escape") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  if (key.ctrl && key.name === "l") {
    continue;
  }

  if (key.ctrl && key.name === "u") {
    if (moveStack.length === 1) {
      continue;
    }

    const currentBindings = moveStack.pop()!;
    moveStack.splice(1);

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < currentBindings.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    myTty.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.length = 0;

    const n = myTty
      .cursorHide
      .text(`${colors.brightBlack("")} `)
      .cursorSave
      .cursorNextLine;
    for (const line of toTable(moveStack.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  if (key.name === "backspace" || (key.ctrl && key.name === "w")) {
    if (moveStack.length === 1) {
      continue;
    }

    const currentBindings = moveStack.pop()!;

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < currentBindings.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    myTty.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.pop();

    const n = myTty
      .cursorHide
      .text(`${colors.brightBlack("")} ${inputKeys.join(colors.brightBlack(" » "))}${inputKeys.length > 0 ? " " : ""}`)
      .cursorSave
      .cursorNextLine;
    for (const line of toTable(moveStack.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  let inputKey = key.name.replace("space", "SPC");
  if (key.shift) {
    inputKey = inputKey.toUpperCase();
  }
  inputKeys.push(inputKey);

  const match = moveStack.at(-1)!.find((b) => b.key === inputKey);
  if (!match) {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.log(`"${inputKeys.join(" ")}" is undefined`);

    Deno.exit(2);
  }

  if (match.type === "command") {
    myTty.cursorHide.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.log(`${match.buffer}\t${Number(match.eval ?? false)}\t${match.trigger ?? ""}`);

    Deno.exit(0);
  }

  if (match.type === "bindings") {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    myTty.cursorTo(initCursorPos.x, initCursorPos.y);

    const n = myTty
      .cursorHide
      .text(`${colors.brightBlack("")} ${inputKeys.join(colors.brightBlack(" » "))} `).cursorSave
      .cursorNextLine;
    for (const line of toTable(match.bindings).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    moveStack.push(match.bindings);
  }
}
