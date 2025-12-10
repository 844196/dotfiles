```console
% GH_CONFIG_DIR=~/.local/state/gh/<GITHUB_USERNAME> gh auth login --web
```

```toml
[env]
GH_CONFIG_DIR = "{{env.HOME}}/.local/state/gh/<GITHUB_USERNAME>"

[[hooks.enter]]
shell = "zsh"
script = "export GITHUB_TOKEN=$(gh auth token --user <GITHUB_USERNAME>)"
```
