import { Hono } from '@hono/hono'
import { hc } from '@hono/hono/client'
import { logger } from '@hono/hono/logger'
import { PatternRouter } from '@hono/hono/router/pattern-router'
import { zValidator } from '@hono/zod-validator'
import { z } from '@zod/zod/mini'

const MessageSchema = z.object({
  url: z.string().check(z.minLength(1)),
  profile: z.optional(z.string().check(z.regex(/^Profile \d+$/))),
})

export const server = new Hono({
  // https://hono.dev/docs/concepts/routers#patternrouter
  router: new PatternRouter(),

  // https://github.com/orgs/honojs/discussions/4145#discussioncomment-13181621
  getPath: (req) => new URL(req.url).pathname,
})
  .use(logger())
  .post('/open', zValidator('json', MessageSchema), (ctx) => {
    const { url, profile } = ctx.req.valid('json')

    const profileOpt = profile === undefined ? '' : `--profile-directory="""${profile}"""`
    const chromeArgs = [profileOpt, `"${url}"`].filter(Boolean).join(', ')
    const cmd = new Deno.Command('/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe', {
      args: ['Start-Process', '-FilePath chrome', `-ArgumentList ${chromeArgs}`],
    })

    const { success, stderr } = cmd.outputSync()
    if (!success) {
      return ctx.json({ status: 'error', message: new TextDecoder().decode(stderr) }, 500)
    }

    return ctx.json({ status: 'ok' as const })
  })

export const createClient = (socketPath: string) => {
  const socketClient = Deno.createHttpClient({ proxy: { transport: 'unix', path: socketPath } })

  return hc<typeof server>('http://localhost/', {
    fetch: (input: RequestInfo | URL, init?: RequestInit) => fetch(input, { ...init, client: socketClient }),
  })
}
