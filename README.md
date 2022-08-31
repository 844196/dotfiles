<h1 align="center">
  <img
    src="https://raw.githubusercontent.com/jglovier/dotfiles-logo/main/dotfiles-logo.png"
    width="320px"
  />
</h1>

## :package: Install

```bash
sh -c "$(curl -fsLS chezmoi.io/get)" -- -b ~/.local/bin init --apply 844196
```

```bash
git clone https://github.com/844196/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

## :framed_picture: Wallpaper

```bash
convert -size 3840x2160 xc:'#161821' wallpaper.png
```

## :construction_worker: Debug

```bash
# in host
echo "HOST_UID=$(id -u)" >> .env
echo "HOST_GID=$(id -g)" >> .env
docker compose build
docker compose run --rm -i sandbox
```

```bash
# in container
.dotfiles/install.sh
```

## :page_facing_up: License

See [`LICENSE.md`](/LICENSE.md). [Logo](https://github.com/jglovier/dotfiles-logo) by [Joel Glovier](https://github.com/jglovier).
