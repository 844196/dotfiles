<p align="center">
  <img
    src="https://raw.githubusercontent.com/jglovier/dotfiles-logo/main/dotfiles-logo.png"
    width="320px"
  />
</p>

---

## 📦 Install

```console
$ sh -c "$(curl -fsLS git.io/chezmoi)" -- -b ~/.local/bin init --apply 844196
```

## 👷 Debug

```console
$ docker build -t dotfiles:latest --build-arg username=alice .
$ docker run --rm -it -v `pwd`:/home/alice/.dotfiles dotfiles:latest
```

## 📄 License

See [`LICENSE.md`](/LICENSE.md). [Logo](https://github.com/jglovier/dotfiles-logo) by [Joel Glovier](https://github.com/jglovier).
