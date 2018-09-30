# Build and run this image with command like below
#
#   docker build -t="tsutomu/fedora-dot-test" .
#   docker run --name fedora-dot-test --hostname fedora-dot-test --volume ${PWD}:/home/foo/dotfiles -ti tsutomu/fedora-dot-test /bin/bash
#
FROM fedora:latest

# RUN pacman -Syu --noconfirm
RUN dnf update -y
RUN dnf install -y passwd sudo fontconfig findutils make
RUN sed -i.org -e 's/^\(\%wheel.*\)/# \1/g' /etc/sudoers
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
RUN useradd -s /bin/bash -d /home/foo -m foo
RUN usermod -aG wheel foo

