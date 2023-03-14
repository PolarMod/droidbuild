FROM ubuntu:focal

# Install packages for droidbuild and android
RUN ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3 python2 scrypt secure-delete
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get update -y
RUN apt-get install -y wget ccache libncurses5 bc xxd cgpt git-core gnupg flex libssl-dev bison gperf libsdl1.2-dev squashfs-tools rsync build-essential zip curl kmod libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev lib32readline-dev gcc-multilib maven tmux screen w3m ncftp
## Install git-lfs
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
RUN apt-get install -y git-lfs

# Prepare directory structure
WORKDIR /
RUN mkdir -p /opt/droid
RUN mkdir -p /opt/droid/buildroot
RUN mkdir -p /opt/droid/config
RUN mkdir -p /opt/droid/bin
WORKDIR /opt/droid/buildroot/
RUN mkdir -p bin
RUN mkdir -p droid
RUN mkdir -p droid/out_dir
RUN mkdir -p droid/.repo
RUN mkdir -p droid/.repo/local_manifests

# Install droidbuild
WORKDIR /opt/droid/buildroot
COPY build/droidbuild droidbuild
COPY manifests/* .repo/local_manifests/
# Add container maintaince scripts
COPY scripts/docker/docker-entrypoint.sh /opt/droid/docker-entrypoint.sh
COPY scripts/docker/docker-unpack.sh /opt/droid/docker-unpack.sh
RUN chmod 755 /opt/droid/docker-entrypoint.sh
RUN chmod 755 /opt/droid/docker-unpack.sh

# Download Google's repo tool and set-up python
WORKDIR /opt/droid
RUN ln -sf /usr/bin/python2 /usr/bin/python
RUN curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo
RUN chmod a+x bin/repo
RUN echo "PATH=/opt/droid/bin:$PATH" >> ~/.bashrc

# Prepare build configuration
COPY scripts scripts
RUN chmod 755 scripts/*.sh

# Install build.sh
WORKDIR /tmp
RUN git clone https://github.com/Andrewerr/build.sh
RUN mv /tmp/build.sh/build.sh /usr/bin/build
RUN chmod 755 /usr/bin/build

# Set-up build
WORKDIR /opt/droid/buildroot
COPY build/Buildfile Buildfile

# Create a copy of overridable directories
# for cases when volumes are mounted
RUN cp -r /opt/droid/buildroot /opt/droid/droidpak

# Set the entrypoint
WORKDIR /opt/droid/buildroot/
ENTRYPOINT /bin/bash /opt/droid/docker-entrypoint.sh
