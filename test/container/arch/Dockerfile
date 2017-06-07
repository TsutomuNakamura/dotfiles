# Build and run this image with command like below
#
#   docker build -t="tsutomu/arch-dot-test" .
#   docker run --name arch-dot-test --hostname arch-dot-test --volume ... -ti tsutomu/arch-dot-test /bin/bash
#
FROM dock0/arch:latest

# RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm base
RUN pacman -Sy --noconfirm base-devel
RUN pacman -Sy --noconfirm sudo
RUN pacman -Sy --noconfirm awk
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -d /home/foo -s /bin/bash -m foo
RUN usermod -aG wheel foo
RUN sed -i.org -e 's/#VerbosePkgLists/#VerbosePkgLists\nILoveCandy/g' /etc/pacman.conf

# For you located in Japan
RUN sed -i.org '1s|^|Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch\nServer = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/$repo/os/$arch\n|' /etc/pacman.d/mirrorlist

