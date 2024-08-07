import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/colors.ts";
import { tty } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/tty.ts";
import { KeyCode, parse } from "https://deno.land/x/cliffy@v1.0.0-rc.4/keycode/mod.ts";
import { border as defaultBorder, Table } from "https://deno.land/x/cliffy@v1.0.0-rc.4/table/mod.ts";
import { Color as ColorUtil } from "https://deno.land/x/color@v0.3.0/mod.ts";
import { emojify } from "https://deno.land/x/github_emoji@v0.1.1/mod.ts";
import { deepMerge } from "jsr:@std/collections@1.0.5";
import { join as joinPath } from "jsr:@std/path@1.0.2";
import { parse as parseYaml } from "jsr:@std/yaml@1.0.2";
import { rcFile } from "npm:rc-config-loader@4.1.3";
import { xdgConfig } from "npm:xdg-basedir@5.1.0";
import { z } from "npm:zod@3.23.8";

type Binding =
  & {
    key: string;
    desc: string;
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

const XDG_CONFIG_HOME = xdgConfig ?? Deno.makeTempDirSync();

const bindings = (() => {
  return parseYaml(Deno.readTextFileSync(joinPath(XDG_CONFIG_HOME, "wk", "bindings.yaml"))) as Binding[];
})();

const ANSI256ColorSchema = z.union([
  z.number().int().min(-1).max(255),
  z.string().regex(/^#[0-9a-fA-F]{6}$/),
]);
const ColorSchema = z.union([
  ANSI256ColorSchema,
  z.object({
    color: ANSI256ColorSchema,
    attrs: z.array(z.enum(["bold", "dim", "italic", "underline", "inverse", "hidden", "strikethrough"])).min(1),
  }),
]);
type Color = z.infer<typeof ColorSchema>;

const ContextSchema = z.object({
  continueOnUndefinedKey: z.boolean(),
  outputDelimiter: z.string(),
  symbols: z.object({
    prompt: z.string(),
    breadcrumb: z.string(),
    separator: z.string(),
    group: z.string(),
    keys: z.record(z.string()),
  }),
  colors: z.object({
    prompt: ColorSchema,
    breadcrumb: ColorSchema,
    separator: ColorSchema,
    group: ColorSchema,
    inputKeys: ColorSchema,
    lastInputKey: ColorSchema,
    bindingKey: ColorSchema,
    bindingIcon: ColorSchema,
    bindingDescription: ColorSchema,
  }),
});
type Context = z.infer<typeof ContextSchema>;

const config = (() => {
  const found = rcFile("wk", { configFileName: joinPath(XDG_CONFIG_HOME, "wk", "config") }) ?? { config: {} };
  const parsed = ContextSchema.partial().safeParse(found.config);

  return parsed.success ? parsed.data : {};
})();

const context = deepMerge<Context>({
  continueOnUndefinedKey: false,
  outputDelimiter: "\t",
  symbols: {
    prompt: " ",
    breadcrumb: " » ",
    separator: "➜",
    group: "+",
    keys: {
      space: "␣",
      return: "⏎",
      tab: "⇥",
      up: "↑",
      down: "↓",
      right: "→",
      left: "←",
      home: "⇱",
      end: "⇲",
      pageup: "⇞",
      pagedown: "⇟",
      insert: "⎀",
      delete: "⌦",
      F1: "󱊫",
      F2: "󱊬",
      F3: "󱊭",
      F4: "󱊮",
      F5: "󱊯",
      F6: "󱊰",
      F7: "󱊱",
      F8: "󱊲",
      F9: "󱊳",
      F10: "󱊴",
      F11: "󱊵",
      F12: "󱊶",
      ...config.symbols?.keys,
    },
  },
  colors: {
    prompt: 8,
    breadcrumb: {
      color: 8,
      attrs: ["dim"],
    },
    separator: {
      color: 8,
      attrs: ["dim"],
    },
    group: 8,
    inputKeys: 8,
    lastInputKey: -1,
    bindingKey: -1,
    bindingIcon: 8,
    bindingDescription: 8,
  },
}, config);

const PRINTABLE_ASCII = /^[ -~]$/;

function getSymbol(key: string) {
  return context.symbols.keys[key] ?? key;
}

function color(text: string, givenColor: Color) {
  const ansi256 = (typeof givenColor === "number" || typeof givenColor === "string") ? givenColor : givenColor.color;
  const attrs = (typeof givenColor === "number" || typeof givenColor === "string") ? [] : givenColor.attrs;

  const colorized = ansi256 === -1
    ? text
    : typeof ansi256 === "string"
    ? colors.rgb24(text, ColorUtil.string(ansi256).rgbNumber())
    : colors.rgb8(text, ansi256);

  let attributed = colorized;
  for (const attr of attrs) {
    switch (attr) {
      case "bold":
        attributed = colors.bold(attributed);
        break;
      case "dim":
        attributed = colors.dim(attributed);
        break;
      case "italic":
        attributed = colors.italic(attributed);
        break;
      case "underline":
        attributed = colors.underline(attributed);
        break;
      case "inverse":
        attributed = colors.inverse(attributed);
        break;
      case "hidden":
        attributed = colors.hidden(attributed);
        break;
      case "strikethrough":
        attributed = colors.strikethrough(attributed);
        break;
    }
  }

  return attributed;
}

function renderPrompt(givenKeys: string[]) {
  const prompt = color(context.symbols.prompt, context.colors.prompt);

  const keys: string[] = [];
  for (let i = 0; i < givenKeys.length; i++) {
    const key = givenKeys[i];
    keys.push(
      color(key, i === givenKeys.length - 1 ? context.colors.lastInputKey : context.colors.inputKeys),
    );
  }

  return `${prompt}${keys.join(color(context.symbols.breadcrumb, context.colors.breadcrumb))}${
    givenKeys.length > 0 ? " " : ""
  }`;
}

const plainBorder = Object.entries(defaultBorder)
  .reduce<Record<string, string>>(
    (acc, [k]) => {
      acc[k] = "";
      return acc;
    },
    {},
  );

function renderTableRow(binding: Binding) {
  const icon = typeof binding.icon === "string" ? color(emojify(binding.icon), context.colors.bindingIcon) : "";
  const group = binding.type === "bindings" ? color(context.symbols.group, context.colors.group) : "";
  const desc = color(binding.desc, context.colors.bindingDescription);

  return [
    color(getSymbol(binding.key), context.colors.bindingKey),
    `${icon}${group}${desc}`,
  ];
}

function renderTable(bindings: Binding[]) {
  return Table
    .from(bindings.map(renderTableRow))
    .border(true).chars({ ...plainBorder, middle: color(context.symbols.separator, context.colors.separator) });
}

// --------------------------------------------------------------------------------

const [ttyReader, ttyWriter] = await Promise.all([
  Deno.open("/dev/tty", { read: true, write: false }),
  Deno.open("/dev/tty", { read: false, write: true }),
]);
const myTty = tty({ reader: ttyReader, writer: ttyWriter });

async function* keypress(): AsyncGenerator<KeyCode, void> {
  while (true) {
    const data = new Uint8Array(8);

    ttyReader.setRaw(true);
    const numberOfBytesRead = await ttyReader.read(data);
    ttyReader.setRaw(false);

    if (numberOfBytesRead === null) {
      return;
    }

    const keys: Array<KeyCode> = parse(data.subarray(0, numberOfBytesRead));
    for (const key of keys) {
      yield key;
    }
  }
}

const initCursorPos = myTty.getCursorPosition();

// zle -M などによってプロンプト下に出力が残っている可能性があるため、あらかじめ表示予定領域をクリアしておく
const o = myTty.cursorHide.eraseLine.cursorNextLine;
for (let i = 0; i < bindings.length; i++) {
  o.eraseLine.cursorNextLine();
}
o.cursorTo(initCursorPos.x, initCursorPos.y);

const inputKeys: string[] = [];
const navigation: [Binding[], ...(Binding[])[]] = [bindings];

myTty
  .cursorHide
  .eraseLine
  .text(renderPrompt(inputKeys)).cursorSave
  .cursorNextLine
  .text(renderTable(bindings).toString())
  .cursorRestore
  .cursorShow();

for await (const key of keypress()) {
  // TODO タイムアウト

  // Failed to parse key
  if (typeof key.name === "undefined") {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < navigation.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    console.error("Failed to parse key", key);

    Deno.exit(128);
  }

  // ^C or ^D (EOF) or ^[ (Escape) => 終了
  if ((key.ctrl && key.name === "c") || (key.ctrl && key.name === "d") || (key.name === "escape")) {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < navigation.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

    Deno.exit(1);
  }

  // ^H (Backspace) or ^W (Delete word) => 一階層戻る
  if (key.name === "backspace" || (key.ctrl && key.name === "w")) {
    // TODO 連打してると意図せず終了して鬱陶しいかもしれないので、無視するオプションを追加
    if (navigation.length === 1) {
      const o = myTty.cursorHide.eraseLine.cursorNextLine;
      for (let i = 0; i < navigation.at(-1)!.length; i++) {
        o.eraseLine.cursorNextLine();
      }
      o.cursorTo(initCursorPos.x, initCursorPos.y).cursorShow();

      Deno.exit(1);
    }

    const currentBindings = navigation.pop()!;

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < currentBindings.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.pop();

    const n = myTty
      .cursorHide
      .text(renderPrompt(inputKeys))
      .cursorSave
      .cursorNextLine;
    for (const line of renderTable(navigation.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine();
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  // ^U (Delete line) => 一番最初の階層に戻る
  if (key.ctrl && key.name === "u") {
    if (navigation.length === 1) {
      continue;
    }

    const currentBindings = navigation.pop()!;
    navigation.splice(1);

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < currentBindings.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    inputKeys.length = 0;
    const n = myTty
      .cursorHide
      .text(renderPrompt(inputKeys))
      .cursorSave
      .cursorNextLine;
    for (const line of renderTable(navigation.at(-1)!).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine;
    }
    n.cursorRestore.cursorShow();

    continue;
  }

  // 上記以外の ^L のような制御文字 => 無視
  if (key.ctrl && PRINTABLE_ASCII.test(key.name)) {
    continue;
  }

  const inputKey = key.shift ? key.name.toUpperCase() : key.name;
  inputKeys.push(getSymbol(inputKey));

  // 未定義キー => エラーにして終了
  // TODO 無視するオプションを追加
  const match = navigation.at(-1)!.find((b) => b.key === inputKey);
  if (!match) {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < navigation.at(-1)!.length; i++) {
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
      desc: __,
      icon: ___,
      type: ____,
      buffer,
      delimiter: definedDelimiter,
      ...rest
    } = match;

    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < navigation.at(-1)!.length; i++) {
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

    const delimiter = typeof definedDelimiter === "string" ? definedDelimiter : context.outputDelimiter;
    console.log(outputs.join(delimiter));

    Deno.exit(0);
  }

  // マッチ: バインディング => 一階層進む
  if (match.type === "bindings") {
    const o = myTty.cursorHide.eraseLine.cursorNextLine;
    for (let i = 0; i < navigation.at(-1)!.length; i++) {
      o.eraseLine.cursorNextLine();
    }
    o.cursorTo(initCursorPos.x, initCursorPos.y);

    // TODO 画面がチラつく
    const n = myTty
      .cursorHide
      .text(renderPrompt(inputKeys))
      .cursorSave
      .cursorNextLine;
    for (const line of renderTable(match.bindings).toString().split("\n")) {
      n.eraseLine.text(line).cursorNextLine();
    }
    n.cursorRestore.cursorShow();

    navigation.push(match.bindings);
  }
}
