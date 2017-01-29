# Build and run this image with command like below
#
#   docker build -t="tsutomu/fedora-dot-test" .
#   docker run --name fedora-dot-test --hostname fedora-dot-test --volume ... -ti tsutomu/fedora-dot-test /bin/bash
#
FROM fedora:latest

# RUN pacman -Syu --noconfirm
RUN dnf update -y
RUN dnf install -y passwd sudo fontconfig findutils
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel.conf
RUN useradd -s /bin/bash -d /home/foo -m foo
RUN usermod -aG wheel foo

