FROM debian:10 as build-env

RUN echo "deb http://ftp.debian.org/debian buster-backports main" >> /etc/apt/sources.list  && \
    apt-get update && apt-get upgrade && \
    apt-get install -y \
	    bash-completion \
    	    bc \
	    binutils-dev \
	    bison \
    	    build-essential \
	    cdbs \
	    cpio \
	    debhelper/buster-backports \
	    dh-systemd \
	    dkms \
	    dwz/buster-backports \
    	    flex \
    	    gcc-arm-linux-gnueabi \
	    gawk \
    	    git \
	    git-buildpackage \
	    gnat \
	    golang-go \
	    kmod \
	    libbz2-dev \
	    libdw-dev \
	    libelf-dev \
	    libftdi1-dev \
	    liblzo2-dev \
	    libncurses5-dev \
	    libpci-dev \
	    libsnappy-dev \
	    libusb-1.0.0-dev \
	    libusb-dev \
	    linux-headers-amd64/buster-backports \
	    linux-image-amd64/buster-backports \
	    quilt \
	    rsync \
	    u-boot-tools

RUN cd && \
    git clone --depth=1 --no-single-branch https://github.com/platinasystems/golang-1.16 -b golang-1.16 && \
    cd golang-1.16 && \
    gbp buildpackage --git-ignore-branch -us -uc && \
    cd .. && \
    dpkg -i golang-1.16*.deb && \
    rm /usr/bin/go && \
    ln -s ../lib/go/bin/go /usr/bin/go && \
    rm /usr/lib/go && \
    ln -s go-1.16 /usr/lib/go

RUN cd && \
    git clone --depth=1 --no-single-branch https://github.com/platinasystems/goes-build -b master && \
    cd goes-build && \
    make bindeb-pkg && \
    cd .. && \
    dpkg -i goes-build*.deb

RUN echo "jenkins:x:111:118:Jenkins,,,:/var/lib/jenkins:/bin/bash" >> /etc/passwd && \
    echo "jenkins:x:118:" >> /etc/group && \
    mkdir -p /var/lib/jenkins && \
    chown jenkins:jenkins /var/lib/jenkins
