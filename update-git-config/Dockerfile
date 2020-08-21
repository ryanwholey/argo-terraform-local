FROM debian:buster

RUN apt-get update && \
  apt-get install -y \
  git \
  curl \
  vim

RUN curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/3.3.2/yq_linux_386 && \
  chmod +x /usr/local/bin/yq

COPY update-git-config.sh update-git-config.sh

