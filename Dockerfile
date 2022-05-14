FROM ubuntu:22.04 as builder

RUN mkdir -p /build
WORKDIR /build
COPY qt-everywhere-src-6.3.0.tar.xz .
RUN apt-get update && apt-get install -y xz-utils
RUN tar -xf qt-everywhere-src-6.3.0.tar.xz && mv qt-everywhere-src-6.3.0 qt

# https://github.com/fffaraz/docker-qt/blob/master/Dockerfile.static
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt -y update && \
    apt -y upgrade && \
    apt -y install \
        build-essential cmake clang libclang-dev freeglut3-dev gdb git iputils-ping libgl1-mesa-dev \
        libglu1-mesa-dev libjpeg-dev libmysqlclient-dev libnss3-dev libopus-dev \
        libfontconfig1-dev libfreetype6-dev libxext-dev libxfixes-dev libwayland-dev libgles2-mesa-dev \
        libpng-dev libsqlite3-dev libssl-dev libx11-dev libx11-xcb-dev libxcb-xinerama0-dev \
        libxcb-xkb-dev libxcb1-dev libxcursor-dev libxi-dev libxml2-dev libxrender-dev \
        libxslt-dev lzip mesa-common-dev nano perl python3-pip valgrind wget zlib1g-dev \
        '^libxcb.*-dev' libxkbcommon-dev libxkbcommon-x11-dev libgl-dev libdouble-conversion-dev && \
    apt -y autoremove && \
    apt -y autoclean && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    exit 0

RUN mkdir -p ./scripts/utils
COPY ./scripts/utils/qt6_compile.sh ./scripts/utils/ 
COPY ./scripts/utils/commons.sh ./scripts/utils/
RUN ./scripts/utils/qt6_compile.sh ./qt qt
ENV PATH="/build/qt/qt/bin:${PATH}"

RUN apt -y update && apt install -y \
    rustc \
    cargo \
    golang \
    wireguard \
    wireguard-tools \
    libpolkit-gobject-1-dev \
    python3-pip

COPY ./requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .
RUN ./scripts/utils/generate_glean.py && \
    ./scripts/utils/import_languages.py && \
    qmake && \
    make -j$(nproc)



