import { clientCommand } from './sub-commands/client-command.ts'

await clientCommand
  .name('chroma-open')
  .parse(Deno.args)
