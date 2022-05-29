<p align="center">
  <img
    src="https://raw.githubusercontent.com/jglovier/dotfiles-logo/main/dotfiles-logo.png"
    width="320px"
  />
</p>

---

## 📦 Install

```bash
sh -c "$(curl -fsLS chezmoi.io/get)" -- -b ~/.local/bin init --apply 844196
```

## 👷 Debug

```bash
echo "HOST_UID=$(id -u)" >> .env
echo "HOST_GID=$(id -g)" >> .env
docker compose build
docker compose run workspace /bin/bash -c .dotfiles/install.sh
```

## 📄 License

See [`LICENSE.md`](/LICENSE.md). [Logo](https://github.com/jglovier/dotfiles-logo) by [Joel Glovier](https://github.com/jglovier).
