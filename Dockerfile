FROM fedora:latest

RUN dnf -y upgrade

RUN dnf install -y --nodocs \
        alsa-lib-devel \
        bison \
        cargo \
        ccache \
        clang-devel \
        cmake \
        cups-devel \
        dbus-glib-devel \
        expat-devel \
        flex \
        git \
        gperf \
        gtk3-devel \
        lcms2-devel \
        libdrm-devel \
        libSM-devel \
        libstdc++-static \
        libvpx-devel \
        libwebp-devel \
        lld \
        llvm-devel \
        lshw \
        mercurial \
        mesa-libgbm-devel \
        mold \
        ninja-build \
        nodejs \
        nss-devel \
        opus-devel \
        patch \
        pciutils-devel \
        perl-English \
        pulseaudio-libs-devel \
        python3-devel \
        python3-html5lib \
        re2-devel \
        redhat-lsb-core \
        snappy-devel \
        time \
        unzip && \
    dnf clean all -y
