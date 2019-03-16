# Build and run this image with command like below
#
#   docker build -t="tsutomu/arch-dot-test" .
#   docker run --name arch-dot-test --hostname arch-dot-test --volume /path/to/your/dotfiles:/home/foo/dotfiles -ti tsutomu/arch-dot-test /bin/bash
#
FROM archlinux/base

# For you located in Japan
RUN sed -i.org '1s|^|Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch\nServer = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/$repo/os/$arch\n|' /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm
#RUN pacman -Sy --noconfirm base base-devel sudo awk git inotify-tools make
RUN pacman -Sy --noconfirm base sudo awk git inotify-tools make
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN useradd -d /home/foo -s /bin/bash -m foo
RUN usermod -aG wheel foo
RUN sed -i.org -e 's/#VerbosePkgLists/#VerbosePkgLists\nILoveCandy/g' /etc/pacman.conf

RUN sed -i -e 's/^#\(en_US.UTF-8.*\)$/\1/g' /etc/locale.gen ;\
    sed -i -e 's/^#\(ja_JP.UTF-8.*\)$/\1/g' /etc/locale.gen ;\
    locale-gen ;\
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

