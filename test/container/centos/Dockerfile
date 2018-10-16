# Build and run this image with command like below
#
#   docker build -t="tsutomu/centos-dot-test" .
#   docker run --name centos-dot-test --hostname centos-dot-test --volume ... -ti tsutomu/centos-dot-test /bin/bash
#
FROM centos:latest

# RUN pacman -Syu --noconfirm
RUN yum update -y
RUN yum install -y sudo fontconfig make
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 ;\
    localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8;\
    localedef -v -c -i zh_CN -f UTF-8 zh_CN.UTF-8; true
ENV LANG en_US.UTF-8
RUN sed -i -e 's/^\(\%wheel\s\+.*\)/# \1/g' /etc/sudoers
RUN sed -i -e 's/\# \(\%wheel.*NOPASSWD: ALL$\)/\1/g' /etc/sudoers
RUN useradd -s /bin/bash -d /home/foo -m foo
RUN usermod -aG wheel foo

