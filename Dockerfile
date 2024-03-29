# syntax=docker/dockerfile:1.3-labs

FROM debian:bullseye

RUN --mount=type=cache,target=/var/lib/apt/lists --mount=type=cache,target=/var/cache/apt/archives <<SHELL
  apt-get update
  apt-get install --yes --no-install-recommends sudo=* gosu=* curl=* ca-certificates=* git=1:2.* zsh=* less=*
SHELL

RUN <<SHELL
  useradd --shell /bin/zsh --create-home testuser
  echo "testuser ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/testuser
  chmod 0440 /etc/sudoers.d/testuser
SHELL

COPY --chmod=755 <<'EOF' /usr/local/bin/docker-entrypoint.sh
#!/bin/bash
usermod --non-unique --uid ${HOST_UID:-9001} testuser
groupmod --gid ${HOST_GID:-9001} testuser
exec /usr/sbin/gosu testuser "$@"
EOF

WORKDIR /home/testuser

RUN rm /home/testuser/.profile /home/testuser/.bashrc /home/testuser/.bash_logout

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/bin/zsh"]
