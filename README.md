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
git clone https://github.com/844196/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

## :framed_picture: Wallpaper

![desktop](https://user-images.githubusercontent.com/4990822/187770964-2f1a4501-46ad-41e0-9a5c-e5497594cebc.png)

```bash
convert -size 3840x2160 xc:'#161821' wallpaper.png
```

## :construction_worker: Debug

```bash
docker compose build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g)
MISE_GITHUB_TOKEN=$(gh auth token) docker compose run --rm sandbox ./install.sh
```

## :page_facing_up: License

See [`LICENSE.md`](/LICENSE.md). [Logo](https://github.com/jglovier/dotfiles-logo) by [Joel Glovier](https://github.com/jglovier).
