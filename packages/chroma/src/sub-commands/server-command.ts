import { Command } from '@cliffy/command'
import { join as joinPath } from 'node:path'
import { DEFAULT_SOCKET_NAME } from '../const.ts'
import { server } from '../server.ts'

export const serverCommand = new Command()
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
