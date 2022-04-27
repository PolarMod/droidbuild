FROM ubuntu:latest

# Install droidbuild
RUN ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3 python2 scrypt secure-delete
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get update -y
RUN apt-get install -y wget ccache libncurses5 bc xxd cgpt git-core gnupg flex libssl-dev bison gperf libsdl1.2-dev squashfs-tools rsync build-essential zip curl kmod libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev lib32readline-dev gcc-multilib maven tmux screen w3m ncftp

# Prepare directory structure
WORKDIR /root
RUN mkdir -p bin
RUN mkdir -p droid
RUN mkdir -p droid/out_dir
RUN mkdir -p droid/.repo
RUN mkdir -p droid/.repo/local_manifests

# Install droidbuild
WORKDIR /root/droid
COPY build/droidbuild droidbuild
COPY manifests/* .repo/local_manifests/

# Download Google's repo tool and set-up python
WORKDIR /root
RUN ln -sf /usr/bin/python2 /usr/bin/python
RUN curl https://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo
RUN chmod a+x bin/repo
RUN echo "PATH=~/bin:$PATH" >> .bashrc

# Prepare build configuration
COPY manifests manifests
COPY scripts scripts
COPY config.sh config.sh
RUN chmod 755 scripts/*.sh

# Install build.sh
WORKDIR /tmp
RUN git clone https://github.com/Andrewerr/build.sh
RUN mv /tmp/build.sh/build.sh /usr/bin/build
RUN chmod 755 /usr/bin/build

# Set-up build
WORKDIR /root/droid
COPY build/Buildfile Buildfile
ENTRYPOINT build droid
