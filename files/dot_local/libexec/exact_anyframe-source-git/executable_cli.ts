#!/usr/bin/env -S deno run -A

import { Command, simpleGit } from "./deps.ts";
import { branch } from "./branch/mod.ts";
import { status } from "./status/mod.ts";

const git = simpleGit();

await new Command()
  .command(
    "status",
    new Command().action(async () => {
      console.log(await status(git));
    }),
  )
  .command(
    "branch",
    new Command().action(async () => {
      console.log(await branch(git));
    }),
  )
  .parse(Deno.args);
