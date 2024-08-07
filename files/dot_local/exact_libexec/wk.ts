import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/colors.ts";
import { tty } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/tty.ts";
import { KeyCode, parse } from "https://deno.land/x/cliffy@v1.0.0-rc.4/keycode/mod.ts";
import { border as defaultBorder, Table } from "https://deno.land/x/cliffy@v1.0.0-rc.4/table/mod.ts";
import { parse as parseYaml } from "jsr:@std/yaml";

type Binding =
  & {
    key: string;
    name: string;
    icon?: string;
  }
  & ({
    type: "command";
    buffer: string;
    [k: string]: unknown; // Expected: string, boolean, number
  } | {
    type: "bindings";
    bindings: Binding[];
  });

const ASCII = /^[ -~]$/;

const OUTPUT_DELIMITER = Deno.env.get("WK_OUTPUT_DELIMITER") ?? "\t";

const UI_SYMBOLS = {
  PROMPT: Deno.env.get("WK_SYMBOL_PROMPT") ?? " ",
  BREADCRUMB: Deno.env.get("WK_SYMBOL_BREADCRUMB") ?? " » ",
  SEPARATOR: Deno.env.get("WK_SYMBOL_SEPARATOR") ?? "➜",
  GROUP: Deno.env.get("WK_SYMBOL_GROUP") ?? "+",
} as const;

const KEY_SYMBOLS: Record<string, string> = {
  "space": "␣",
  "escape": "⎋",
  "return": "⏎",
  "tab": "⇥",
  "up": "↑",
  "down": "↓",
  "right": "→",
  "left": "←",
  "home": "⇱",
  "end": "⇲",
  "pageUp": "⇞",
  "pageDown": "⇟",
  "delete": "⌦",
};

function getSymbol(key: string) {
  return Deno.env.get(`WK_SYMBOL_${key.toUpperCase()}`) ?? KEY_SYMBOLS[key] ?? key;
}

// --------------------------------------------------------------------------------

const [ttyReader, ttyWriter] = await Promise.all([
  Deno.open("/dev/tty", { read: true, write: false }),
  Deno.open("/dev/tty", { read: false, write: true }),
]);

const myTty = tty({
  reader: ttyReader,
  writer: ttyWriter,
});

async function* keypress(): AsyncGenerator<KeyCode, void> {
  while (true) {
    const data = new Uint8Array(8);

    ttyReader.setRaw(true);
    const nread = await ttyReader.read(data);
    ttyReader.setRaw(false);

    if (nread === null) {
      return;
    }

    const keys: Array<KeyCode> = parse(data.subarray(0, nread));

    for (const key of keys) {
      yield key;
    }
  }
}

const bindings = parseYaml(
  Deno.readTextFileSync(`${Deno.env.get("XDG_CONFIG_HOME") ?? "~/.config"}/wk/bindings.yaml`),
) as Binding[];

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
      bindings.map((item) => [
        colors.white(getSymbol(item.key)),
        colors.brightBlack(
          // TODO emojify
          `${item.icon ?? ""}${item.type === "bindings" ? UI_SYMBOLS.GROUP : ""}${item.name}`,
        ),
      ]),
    )
    .border(true).chars({ ...plainBorder, middle: colors.brightBlack.dim(UI_SYMBOLS.SEPARATOR) });
}

// zle -M などによってプロンプト下に出力が残っている可能性があるため、あらかじめ表示予定領域をクリアしておく
const o = myTty.cursorHide.eraseLine.cursorNextLine;
for (let i = 0; i < bindings.length; i++) {
  o.eraseLine.cursorNextLine();
}
o.cursorTo(initCursorPos.x, initCursorPos.y);

myTty
  .cursorHide
  .eraseLine
  .text(colors.brightBlack(UI_SYMBOLS.PROMPT)).cursorSave
  .cursorNextLine
  .text(toTable(bindings).toString())
  .cursorRestore
  .cursorShow();

const moveStack: [Binding[], ...(Binding[])[]] = [bindings];
const inputKeys = [];
for await (const key of keypress()) {
  // TODO タイムアウト

  // Failed to parse key
  if (typeof key.name === "undefined") {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.error("Failed to parse key", key);

    Deno.exit(128);
  }

  // ^C or ^D (EOF) or ^[ (Escape) => 終了
  if ((key.ctrl && key.name === "c") || (key.ctrl && key.name === "d") || (key.name === "escape")) {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  // ^H (Backspace) or ^W (Delete word) => 一階層戻る
  if (key.name === "backspace" || (key.ctrl && key.name === "w")) {
    // TODO 連打してると意図せず終了して鬱陶しいかもしれないので、無視するオプションを追加
    if (moveStack.length === 1) {
      const o = myTty.cursorHide.eraseLine.cursorNextLine;
      for (let i = 0; i < moveStack.at(-1)!.length; i++) {
        o.eraseLine.cursorNextLine();
      }
      o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

      Deno.exit(1);
    }

    const currentBindings = moveStack.pop()!;

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < currentBindings.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.pop();

    const n = myTty
      .cursorHide
      .text(
        `${colors.brightBlack(UI_SYMBOLS.PROMPT)}${inputKeys.join(colors.brightBlack(UI_SYMBOLS.BREADCRUMB))}${
          inputKeys.length > 0 ? " " : ""
        }`,
      )
      .cursorSave
      .cursorNextLine;
    for (const line of toTable(moveStack.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  // ^U (Delete line) => 一番最初の階層に戻る
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
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.length = 0;
    const n = myTty
      .cursorHide
      .text(
        `${colors.brightBlack(UI_SYMBOLS.PROMPT)}${inputKeys.join(colors.brightBlack(UI_SYMBOLS.BREADCRUMB))}${
          inputKeys.length > 0 ? " " : ""
        }`,
      )
      .cursorSave
      .cursorNextLine;
    for (const line of toTable(moveStack.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  // 上記以外の ^L のような制御文字 => 無視
  if (key.ctrl && ASCII.test(key.name)) {
    continue;
  }

  const inputKey = key.shift ? key.name.toUpperCase() : key.name;
  inputKeys.push(getSymbol(inputKey));

  // 未定義キー => エラーにして終了
  // TODO 無視するオプションを追加
  const match = moveStack.at(-1)!.find((b) => b.key === inputKey);
  if (!match) {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.error(`"${inputKeys.join(" ")}" is undefined`);

    Deno.exit(2);
  }

  // マッチ: コマンド => 出力して終了
  if (match.type === "command") {
    const {
      key: _,
      name: __,
      icon: ___,
      type: ____,
      buffer,
      delimiter: definedDelimiter,
      ...rest
    } = match;

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    const outputs = [buffer];
    for (const [k, v] of Object.entries(rest)) {
      switch (typeof v) {
        case "string":
          outputs.push(`${k}:${v}`);
          break;

        case "number":
        case "boolean":
          outputs.push(`${k}:${JSON.stringify(v)}`);
          break;

        default:
          break;
      }
    }

    const delimiter = typeof definedDelimiter === "string" ? definedDelimiter : OUTPUT_DELIMITER;
    console.log(outputs.join(delimiter));

    Deno.exit(0);
  }

  // マッチ: バインディング => 一階層進む
  if (match.type === "bindings") {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < moveStack.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    // TODO 画面がチラつく
    const n = myTty
      .cursorHide
      .text(
        `${colors.brightBlack(UI_SYMBOLS.PROMPT)}${inputKeys.join(colors.brightBlack(UI_SYMBOLS.BREADCRUMB))}${
          inputKeys.length > 0 ? " " : ""
        }`,
      )
      .cursorSave
      .cursorNextLine;
    for (const line of toTable(match.bindings).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    moveStack.push(match.bindings);
  }
}
