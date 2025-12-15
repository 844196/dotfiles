import { Command } from '@cliffy/command'
import { match, P } from '@gabriel/ts-pattern'
import { join as joinPath } from 'node:path'
import { DEFAULT_SOCKET_NAME } from '../const.ts'
import { createClient } from '../server.ts'

export const clientCommand = new Command()
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
