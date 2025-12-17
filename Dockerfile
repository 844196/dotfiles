FROM debian:bullseye

ARG USER_UID
ARG USER_GID

RUN \
  useradd --shell /bin/bash --create-home --user-group nonroot && \
  usermod --non-unique --uid ${USER_UID?} nonroot && \
  groupmod --non-unique --gid ${USER_GID?} nonroot

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    # Obviously
    ca-certificates=* \
    zsh=* \
    # For Nerd Fonts
    locales=* \
    # Required by "install.sh"
    curl=* \
    # Required by "deno compile"
    unzip=* \
    # For debugging
    sudo=* \
    && \
  rm -rf /var/lib/apt/lists/*

COPY <<EOF /etc/locale.gen
en_US.UTF-8 UTF-8
ja_JP.UTF-8 UTF-8
EOF

RUN locale-gen
ENV LANG en_US.UTF-8

RUN \
  echo "nonroot ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/nonroot && \
  chmod 0440 /etc/sudoers.d/nonroot

RUN install -o nonroot -g nonroot -d /home/nonroot/.dotfiles

USER nonroot

WORKDIR /home/nonroot/.dotfiles

CMD ["/bin/bash"]
