import { Command } from '@cliffy/command'
import { match, P } from '@gabriel/ts-pattern'
import { join as joinPath } from 'node:path'
import { DEFAULT_SOCKET_NAME } from '../const.ts'
import { createClient } from '../server.ts'

const fileExists = (path: string): boolean => {
  try {
    Deno.lstatSync(path)
    return true
  } catch (e: unknown) {
    if (!(e instanceof Deno.errors.NotFound)) {
      throw e
    }
    return false
  }
}

export const clientCommand = new Command()
  .env('CHROMA_HOST=<host:string>', '', { prefix: 'CHROMA_' })
  .env('CHROMA_RUNTIME_DIR=<path:string>', '')
  .env('XDG_RUNTIME_DIR=<path:string>', '')
  .env('CHROMA_PROFILE=<profile:string>', '', { prefix: 'CHROMA_' })
  .option('-H, --host <host:string>', '')
  .option('-p, --profile <profile:string>', '')
  .arguments('<url:string>')
  .action(async ({ profile, ...runtime }, url) => {
    const socketPath = match(runtime)
      .with({ host: P.string }, ({ host }) => host.replace(/^unix:\/\//, ''))
      .with({ chromaRuntimeDir: P.string }, ({ chromaRuntimeDir }) => joinPath(chromaRuntimeDir, DEFAULT_SOCKET_NAME))
      .with({ xdgRuntimeDir: P.string }, ({ xdgRuntimeDir }) =>
        [
          joinPath(xdgRuntimeDir, 'chroma', DEFAULT_SOCKET_NAME),
          joinPath(xdgRuntimeDir, DEFAULT_SOCKET_NAME),
        ].find(fileExists))
      .with({}, () => undefined)
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
