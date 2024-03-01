ARG SWIFT_VERSION=5.9

FROM swift:${SWIFT_VERSION}

ARG HYLO_LLVM_BUILD_RELEASE=2024-02-29-r2
ARG LLVM_VERSION=17.0.6

ENV HYLO_LLVM_DOWNLOAD_URL="https://github.com/hylo-lang/llvm-build/releases/download"

RUN apt-get clean
RUN apt-get update
RUN apt-get install -y tar zstd libzstd1 libzstd-dev

ADD ${HYLO_LLVM_DOWNLOAD_URL}/${HYLO_LLVM_BUILD_RELEASE}/llvm-${LLVM_VERSION}-x86_64-unknown-linux-gnu-Debug.tar.zst /opt
RUN tar -x --zstd -f /opt/llvm-${LLVM_VERSION}-x86_64-unknown-linux-gnu-Debug.tar.zst -C /opt

ADD ${HYLO_LLVM_DOWNLOAD_URL}/${HYLO_LLVM_BUILD_RELEASE}/llvm-${LLVM_VERSION}-x86_64-unknown-linux-gnu-MinSizeRel.tar.zst /opt
RUN tar -x --zstd -f /opt/llvm-${LLVM_VERSION}-x86_64-unknown-linux-gnu-MinSizeRel.tar.zst -C /opt

ADD ${HYLO_LLVM_DOWNLOAD_URL}/${HYLO_LLVM_BUILD_RELEASE}/llvm-${LLVM_VERSION}-aarch64-unknown-linux-gnu-Debug.tar.zst /opt
RUN tar -x --zstd -f /opt/llvm-${LLVM_VERSION}-aarch64-unknown-linux-gnu-Debug.tar.zst -C /opt

ADD ${HYLO_LLVM_DOWNLOAD_URL}/${HYLO_LLVM_BUILD_RELEASE}/llvm-${LLVM_VERSION}-aarch64-unknown-linux-gnu-MinSizeRel.tar.zst /opt
RUN tar -x --zstd -f /opt/llvm-${LLVM_VERSION}-aarch64-unknown-linux-gnu-MinSizeRel.tar.zst -C /opt

RUN rm /opt/llvm-*.tar.zst
