ARG SWIFT_VERSION

FROM swift:${SWIFT_VERSION}

RUN apt-get update && \
    apt-get install -y \
        libllvm15 llvm-15 llvm-15-dev llvm-15-doc llvm-15-examples llvm-15-runtime libc++-15-dev libc++abi-15-dev

RUN ln -s /usr/bin/llvm-config-15 /usr/bin/llvm-config
