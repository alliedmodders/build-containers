FROM debian:bullseye

ARG CLANG_VERSION=14

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-transport-https lsb-release wget software-properties-common gnupg \
        curl git gcc-multilib g++-multilib jq lib32z1-dev python python3-pip && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh ${CLANG_VERSION} && \
    rm llvm.sh

RUN wget -O /usr/local/bin/dump_syms https://users.alliedmods.net/~psychonic/dump_syms && \
    chmod +x /usr/local/bin/dump_syms

RUN pip3 install git+https://github.com/alliedmodders/ambuild.git

ENV CC=clang-${CLANG_VERSION}
ENV CXX=clang++-${CLANG_VERSION}

CMD ["/bin/bash"]