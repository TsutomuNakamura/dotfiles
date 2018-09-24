# Build and run this image with command like below
#
#   docker build -t="tsutomu/fedora-dot-test" .
#   docker run --name fedora-dot-test --hostname fedora-dot-test --volume ... -ti tsutomu/fedora-dot-test /bin/bash
#
FROM centos:latest

# RUN pacman -Syu --noconfirm
RUN yum update -y
RUN yum install -y sudo fontconfig git make
RUN sed -i -e 's/^\(\%wheel\s\+.*\)/# \1/g' /etc/sudoers
RUN sed -i -e 's/\# \(\%wheel.*NOPASSWD: ALL$\)/\1/g' /etc/sudoers
RUN useradd -s /bin/bash -d /home/foo -m foo
RUN usermod -aG wheel foo

