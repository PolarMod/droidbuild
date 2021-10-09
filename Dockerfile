FROM ubuntu:latest

RUN ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip python3
RUN apt-get install -y openjdk-8-jdk 
RUN apt-get update -y
RUN apt-get install -y wget ccache libncurses5 bc xxd cgpt git-core gnupg flex libssl-dev bison gperf libsdl1.2-dev squashfs-tools rsync build-essential zip curl kmod libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev lib32readline-dev gcc-multilib maven tmux screen w3m ncftp

WORKDIR /root
COPY manifests manifests
COPY vendor_polar polar
COPY external/faceunlock32 faceunlock32
COPY overlays overlays
COPY patches patches
COPY external external
COPY android-certs .android-certs
RUN mkdir -p bin
RUN mkdir -p sakura
RUN mkdir -p sakura/out_dir

RUN ln -sf /usr/bin/python3 /usr/bin/python
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > bin/repo
RUN chmod a+x bin/repo
RUN echo "PATH=~/bin:$PATH" >> .bashrc

WORKDIR /tmp
RUN git clone https://github.com/Andrewerr/build.sh
RUN mv /tmp/build.sh/build.sh /usr/bin/build
RUN chmod 755 /usr/bin/build

WORKDIR /root/sakura
COPY build/Buildfile Buildfile
COPY external external
ENTRYPOINT build all
#RUN /root/bin/repo sync -j8
#RUN ./build/envsetup.sh && lunch hotdogg
