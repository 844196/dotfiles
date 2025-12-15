```bash
GH_CONFIG_DIR=${XDG_STATE_HOME}/gh/<GITHUB_USERNAME> gh auth login --web
```

```toml
# mise.local.toml

[env]
GH_CONFIG_DIR = "{{xdg_state_home}}/gh/<GITHUB_USERNAME>"
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
