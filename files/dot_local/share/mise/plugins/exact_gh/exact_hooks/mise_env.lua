function PLUGIN:MiseEnv(ctx)
  if not ctx.options.user then
    error("user is required in mise.toml configuration")
  end
  local user = ctx.options.user
  local host = ctx.options.host or "github.com"

  local file = require("file")

  return {
    {
      key = "GH_HOST",
      value = host,
    },
    {
      key = "GH_CONFIG_DIR",
      value = file.join_path(os.getenv("XDG_STATE_HOME"), "gh", host, user),
    },
  }
end
