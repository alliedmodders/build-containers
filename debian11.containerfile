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

ARG DUMP_SYMS_VERSION=2.3.7
RUN curl -sSL "https://github.com/mozilla/dump_syms/releases/download/v${DUMP_SYMS_VERSION}/dump_syms-x86_64-unknown-linux-gnu.tar.xz" \
        | tar -xJ --strip-components=1 -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/dump_syms

RUN pip3 install git+https://github.com/alliedmodders/ambuild.git

ENV CC=clang-${CLANG_VERSION}
ENV CXX=clang++-${CLANG_VERSION}

CMD ["/bin/bash"]