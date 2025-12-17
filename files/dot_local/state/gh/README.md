```bash
GH_CONFIG_DIR=${XDG_STATE_HOME}/gh/<GITHUB_USERNAME> gh auth login --web
```

```toml
# fnox.local.toml

[secrets]
GITHUB_TOKEN = { provider = "gh", value = "<GITHUB_USERNAME>" }
```

```toml
# mise.local.toml

[env]
GH_CONFIG_DIR = "{{xdg_state_home}}/gh/<GITHUB_USERNAME>"

[tasks.up]
usage = '''
flag "--remove-existing-container" help="Removes the dev container if it already exists."
'''
run = "fnox x --if-missing error -- devcontainer up --workspace-folder . ${usage_remove_existing_container+--remove-existing-container}"
```

```yaml
# compose.override.yaml

services:
  app:
    environment:
      - GITHUB_TOKEN
```

```bash
GITHUB_TOKEN=$(gh auth token --user <GITHUB_USERNAME>) devcontainer up --workspace-folder . --remove-existing-container
```
