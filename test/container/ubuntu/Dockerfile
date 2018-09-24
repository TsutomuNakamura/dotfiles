# Build and run this image with command like below
#
#   docker build -t="tsutomu/ubuntu-dot-test" .
#   docker run --name ubuntu-dot-test --hostname ubuntu-dot-test --volume ... -ti tsutomu/ubuntu-dot-test /bin/bash
#
FROM ubuntu:xenial
RUN apt-get update
RUN apt-get install -y wget gnupg2
RUN wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget https://www.ubuntulinux.jp/sources.list.d/bionic.list -O /etc/apt/sources.list.d/ubuntu-ja.list
RUN apt-get update
RUN apt-get install -y sudo vim curl git
RUN echo "%adm ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -d /home/foo -s /bin/bash -m foo
RUN usermod -aG adm foo

