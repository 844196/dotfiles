# dotfiles

## Install

```console
$ ./install.sh
```

## Debug

```console
$ docker build -t dotfiles:latest --build-arg username=bob .
$ docker run --rm -it -v `pwd`:/home/bob/.dotfiles dotfiles:latest
```
