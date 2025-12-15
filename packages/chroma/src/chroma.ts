import { Command } from '@cliffy/command'
import { match, P } from '@gabriel/ts-pattern'
import { join as joinPath } from 'node:path'
import { createClient, server } from './server.ts'

const DEFAULT_SOCKET_NAME = 'chroma.sock'

const serverCommand = new Command()
  .env('CHROMA_RUNTIME_DIR=<path:string>', '', { prefix: 'CHROMA_' })
  .env('XDG_RUNTIME_DIR=<path:string>', '')
  .option('--runtime-dir <path:string>', '')
  .action(({ runtimeDir, xdgRuntimeDir }) => {
    const determinedRuntimeDir = runtimeDir ?? xdgRuntimeDir ??
      Deno.makeTempDirSync({ prefix: 'chroma' })
    const socketPath = joinPath(determinedRuntimeDir, DEFAULT_SOCKET_NAME)

    console.log(`Start listening on socket: ${socketPath}`)

    const ac = new AbortController()
    Deno.addSignalListener('SIGINT', () => ac.abort())
    Deno.addSignalListener('SIGTERM', () => ac.abort())

    Deno
      .serve({ path: socketPath, signal: ac.signal }, server.fetch)
      .finished.then(async () => {
        try {
          await Deno.remove(socketPath)
        } catch (err: unknown) {
          if (!(err instanceof Deno.errors.NotFound)) {
            console.error('Failed to remove socket file:', err)
          }
        }
        console.log('Server stopped')
      })
  })

const clientCommand = new Command()
  .alias('open')
  .env('CHROMA_HOST=<host:string>', '', { prefix: 'CHROMA_' })
  .env('CHROMA_RUNTIME_DIR=<path:string>', '')
  .env('XDG_RUNTIME_DIR=<path:string>', '')
  .env('CHROMA_PROFILE=<profile:string>', '', { prefix: 'CHROMA_' })
  .option('-H, --host <host:string>', '')
  .option('-p, --profile <profile:string>', '')
  .arguments('<url:string>')
  .action(async ({ host, chromaRuntimeDir, xdgRuntimeDir, profile }, url) => {
    const socketPath = match([host, chromaRuntimeDir ?? xdgRuntimeDir])
      .with([P.string, P.any], ([left]) => left.replace(/^unix:\/\//, ''))
      .with([undefined, P.string], ([, right]) => joinPath(right, DEFAULT_SOCKET_NAME))
      .with([undefined, undefined], () => undefined)
      .exhaustive()
    if (socketPath === undefined) {
      console.error('Cannot determine chroma host.')
      Deno.exit(1)
    }

    const client = createClient(socketPath)

    const res = await client.open.$post({ json: { url, profile } })
    if (!res.ok) {
      console.error(await res.json())
      Deno.exit(1)
    }
  })

const cmd = new Command()
  .name('chroma')
  .global()
  .action(() => {
    cmd.showHelp()
    Deno.exit(1)
  })
  .command('server', serverCommand)
  .command('client', clientCommand)

await cmd.parse(Deno.args)
