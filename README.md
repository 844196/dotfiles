<div align="center">
  <p>&nbsp;</p>

  <img
    src="https://raw.githubusercontent.com/jglovier/dotfiles-logo/main/dotfiles-logo-icon.png"
    height="150px"
  />

  <h1>dotfiles</h1>

  ~/.📑

  <img src="https://img.shields.io/badge/Windows-%23.svg?style=flat-square&logo=windows&color=0078D6&logoColor=white" />
  <img src="https://img.shields.io/badge/Linux-%23.svg?style=flat-square&logo=linux&color=FCC624&logoColor=black" />
  <img src="https://img.shields.io/badge/macOS-%23.svg?style=flat-square&logo=apple&color=000000&logoColor=white" />
</div>

## :package: Install

```bash
sh -c "$(curl -fsLS chezmoi.io/get)" -- -b ~/.local/bin init --apply 844196
```

```bash
git clone https://github.com/844196/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

### :link: WezTerm shortcut (for Windows)

```
"C:\Program Files\WezTerm\wezterm-gui.exe" --config-file \\wsl.localhost\Ubuntu\home\{{ USERNAME_GOES_HERE }}\.config\wezterm\wezterm.lua --config "default_domain='WSL:Ubuntu'"
```

## :framed_picture: Wallpaper

![desktop](https://user-images.githubusercontent.com/4990822/187770964-2f1a4501-46ad-41e0-9a5c-e5497594cebc.png)

```bash
convert -size 3840x2160 xc:'#161821' wallpaper.png
```

## :construction_worker: Debug

```bash
# in host
echo "HOST_UID=$(id -u)" >> .env
echo "HOST_GID=$(id -g)" >> .env

docker compose build
docker compose run --rm sandbox
```

```bash
# in container
./install.sh
```

## :page_facing_up: License

See [`LICENSE.md`](/LICENSE.md). [Logo](https://github.com/jglovier/dotfiles-logo) by [Joel Glovier](https://github.com/jglovier).
