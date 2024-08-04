import { colors } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/colors.ts";
import { tty } from "https://deno.land/x/cliffy@v1.0.0-rc.4/ansi/tty.ts";
import { KeyCode, parse } from "https://deno.land/x/cliffy@v1.0.0-rc.4/keycode/mod.ts";
import { border as defaultBorder, Table } from "https://deno.land/x/cliffy@v1.0.0-rc.4/table/mod.ts";

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
    trigger?: "ACCEPT" | "COMPLETE";
  } | {
    type: "bindings";
    bindings: Binding[];
  });

let bindings: Binding[] = [
  {
    key: "SPC",
    name: "Insert space",
    type: "command",
    command: " ",
  },
  {
    key: "g",
    name: "Git",
    // icon: " ",
    type: "bindings",
    bindings: [
      {
        key: "b",
        name: "Branch",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "git branch",
            // icon: " ",
            type: "command",
            command: "git branch",
            trigger: "ACCEPT",
          },
          {
            key: "c",
            name: "git checkout",
            type: "command",
            // icon: " ",
            command: "git checkout ",
            trigger: "COMPLETE",
          },
          {
            key: "n",
            name: "git checkout -b",
            type: "command",
            // icon: "󱓊 ",
            command: "git checkout -b ",
            trigger: "COMPLETE",
          },
          {
            key: "r",
            name: "git branch -m",
            // icon: " ",
            type: "command",
            command: "git branch -m ",
            trigger: "COMPLETE",
          },
          {
            key: "d",
            name: "git branch -D",
            // icon: " ",
            type: "command",
            command: "git branch -D ",
            trigger: "COMPLETE",
          },
        ],
      },
      {
        key: "a",
        name: "Add",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "git add",
            type: "command",
            command: "git add ",
            trigger: "COMPLETE",
          },
          {
            key: "a",
            name: "git add -A",
            type: "command",
            command: "git add -A",
          },
        ],
      },
      {
        key: "c",
        name: "Commit",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "git commit ",
            type: "command",
            command: "git commit ",
          },
          {
            key: "m",
            name: "git commit -m",
            type: "command",
            command: "git commit -m ",
            trigger: "COMPLETE",
          },
          {
            key: "a",
            name: "git commit --amend --no-edit",
            type: "command",
            command: "git commit --amend --no-edit",
          },
          {
            key: "f",
            name: "git commit --fixup",
            type: "command",
            command: "git commit --fixup ",
            trigger: "COMPLETE",
          },
        ],
      },
      {
        key: "r",
        name: "Rebase",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "git rebase ",
            type: "command",
            command: "git rebase ",
            trigger: "COMPLETE",
          },
          {
            key: "i",
            name: "git rebase -i",
            type: "command",
            command: "git rebase -i ",
            trigger: "COMPLETE",
          },
        ],
      },
      {
        key: "p",
        name: "Push/Pull",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "git push origin HEAD",
            type: "command",
            command: "git push origin HEAD",
          },
          {
            key: "u",
            name: "git push -u origin HEAD",
            type: "command",
            command: "git push -u origin HEAD",
          },
          {
            key: "f",
            name: "git push --force-with-lease --force-if-includes origin HEAD",
            type: "command",
            command: "git push --force-with-lease --force-if-includes origin HEAD",
          },
          {
            key: "l",
            name: "git pull",
            type: "command",
            command: "git pull",
          },
        ],
      },
      {
        key: "h",
        name: "GitHub",
        // icon: " ",
        type: "bindings",
        bindings: [
          {
            key: "p",
            name: "Pull request",
            // icon: " ",
            type: "bindings",
            bindings: [
              {
                key: "c",
                name: "Create pull request",
                type: "command",
                command: "gh pr create -w -a @me -t ",
                trigger: "COMPLETE",
              },
            ],
          },
        ],
      },
      {
        key: "s",
        name: "Status",
        // icon: " ",
        type: "command",
        command: " git status",
        trigger: "ACCEPT",
      },
      {
        key: "d",
        name: "Diff",
        // icon: " ",
        type: "command",
        command: " git diff",
        trigger: "ACCEPT",
      },
      {
        key: "g",
        // icon: " ",
        name: "git graph -n 10",
        type: "command",
        command: " git graph -n 10",
        trigger: "ACCEPT",
      },
    ],
  },
  {
    key: "d",
    name: "Docker",
    // icon: "󰡨 ",
    type: "bindings",
    bindings: [
      {
        key: "SPC",
        name: "docker ",
        type: "command",
        command: "docker ",
      },
      {
        key: "r",
        name: "docker run",
        type: "command",
        command: "docker run --rm -it ",
      },
      {
        key: "c",
        name: "docker compose",
        type: "bindings",
        bindings: [
          {
            key: "SPC",
            name: "docker compose ",
            type: "command",
            command: "docker compose ",
          },
          {
            key: "u",
            name: "docker compose up",
            type: "command",
            command: "docker compose up",
          },
          {
            key: "d",
            name: "docker compose down",
            type: "command",
            command: "docker compose down",
          },
          {
            key: "r",
            name: "docker compose run",
            type: "command",
            command: "docker compose run --rm",
          },
        ],
      },
    ],
  },
];

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

    console.log(`${match.command}\t${match.trigger ?? ""}`);

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
