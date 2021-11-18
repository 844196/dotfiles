# syntax=docker/dockerfile:1.3-labs
FROM debian:buster

ARG username=john

RUN <<SHELL
  groupadd --gid 1000 ${username}
  useradd --uid 1000 --gid ${username} --shell /bin/bash --create-home ${username}
SHELL

RUN <<SHELL
  apt-get update
  apt-get install -y sudo curl git
  apt-get clean
SHELL

RUN <<SHELL
  echo "${username} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${username}
  chmod 0440 /etc/sudoers.d/${username}
SHELL

USER ${username}
WORKDIR /home/${username}

ENTRYPOINT ["/bin/bash", "-l"]
