FROM ubuntu:24.04

ARG USER_UID
ARG USER_GID

RUN \
  groupmod --gid $USER_GID ubuntu && \
  usermod --uid $USER_UID ubuntu && \
  chown -R $USER_UID:$USER_GID /home/ubuntu

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    # Obviously
    ca-certificates=* \
    git=* \
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
ENV LANG=en_US.UTF-8

RUN \
  echo "ubuntu ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
  chmod 0440 /etc/sudoers.d/ubuntu

RUN install -o ubuntu -g ubuntu -d /home/ubuntu/.dotfiles

USER ubuntu

CMD ["/bin/bash"]
