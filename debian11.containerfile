FROM debian:bullseye AS dump_syms_builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential git && \
    rm -rf /var/lib/apt/lists/*

ARG DUMP_SYMS_VERSION=2.3.7
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install --git https://github.com/mozilla/dump_syms --tag v${DUMP_SYMS_VERSION} --locked

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

RUN pip3 install git+https://github.com/alliedmodders/ambuild.git

COPY --from=dump_syms_builder /root/.cargo/bin/dump_syms /usr/local/bin/dump_syms

ENV CC=clang-${CLANG_VERSION}
ENV CXX=clang++-${CLANG_VERSION}

CMD ["/bin/bash"]