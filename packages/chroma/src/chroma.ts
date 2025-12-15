import { Command } from '@cliffy/command'
import { clientCommand } from './sub-commands/client-command.ts'
import { serverCommand } from './sub-commands/server-command.ts'

const cmd = new Command()
  .name('chroma')
  .global()
  .action(() => {
    cmd.showHelp()
    Deno.exit(1)
  })
  .command('server', serverCommand)
  .command('client', clientCommand).alias('open')

await cmd.parse(Deno.args)
