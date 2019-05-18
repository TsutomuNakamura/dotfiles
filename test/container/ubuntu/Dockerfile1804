# Build and run this image with command like below
#
#   docker build -t="tsutomu/ubuntu1804-dot-test" . -f Dockerfile1804
#   docker run --name ubuntu-dot-test --hostname ubuntu-dot-test --volume ${PWD}:/home/foo/dotfiles -ti tsutomu/ubuntu1804-dot-test /bin/bash
#
FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y wget gnupg2
RUN wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add -
RUN wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add -
RUN wget https://www.ubuntulinux.jp/sources.list.d/bionic.list -O /etc/apt/sources.list.d/ubuntu-ja.list
RUN apt-get update
RUN apt-get install -y sudo vim curl git make locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "%adm ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -d /home/foo -s /bin/bash -m foo
RUN usermod -aG adm foo

