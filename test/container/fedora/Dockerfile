# Build and run this image with command like below
#
#   docker build -t="tsutomu/fedora-dot-test" .
#   docker run --name fedora-dot-test --hostname fedora-dot-test --volume ${PWD}:/home/foo/dotfiles -ti tsutomu/fedora-dot-test /bin/bash
#
FROM fedora:latest

# RUN pacman -Syu --noconfirm
RUN dnf update -y
RUN dnf install -y passwd sudo fontconfig findutils make glibc-common glibc-locale-source
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 ;\
    localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8;\
    localedef -v -c -i zh_CN -f UTF-8 zh_CN.UTF-8; true
ENV LANG en_US.UTF-8
RUN sed -i.org -e 's/^\(\%wheel.*\)/# \1/g' /etc/sudoers
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
RUN useradd -s /bin/bash -d /home/foo -m foo
RUN usermod -aG wheel foo

