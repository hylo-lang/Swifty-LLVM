ARG SWIFT_VERSION=6.1
# Other ARG declarations must follow FROM
FROM swift:${SWIFT_VERSION}

ARG HYLO_LLVM_BUILD_TYPE=MinSizeRel
ARG HYLO_LLVM_BUILD_RELEASE=20250603-162600
ARG HYLO_LLVM_VERSION=17.0.6
ARG CMAKE_VERSION=3.29.1

ENV HYLO_LLVM_DOWNLOAD_URL="https://github.com/hylo-lang/llvm-build/releases/download"

# Install the dependencies for the LLVM build.
# Note that we do cleanup in the same layer to save disk space.
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg curl libzstd-dev libzstd1 lsb-release make \
       ninja-build tar wget zstd software-properties-common python3-full python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Get a recent cmake (https://www.kitware.com/cmake-python-wheels/)
# RUN if $(/usr/bin/which cmake) ; then apt purge --auto-remove cmake ; fi
RUN python3 -m venv python-venv
RUN python-venv/bin/pip install --upgrade cmake


# Get the LLVM builds for the host architecture
RUN <<EOT bash -ex -o pipefail

    file_prefix="llvm-\${HYLO_LLVM_VERSION}-\$(uname -m)-unknown-linux-gnu"
    url_prefix="\${HYLO_LLVM_DOWNLOAD_URL}/\${HYLO_LLVM_BUILD_RELEASE}/\$file_prefix"

    for build_type in Debug MinSizeRel; do
        curl --no-progress-meter -L "\${url_prefix}-\${build_type}.tar.zst" | tar -x --zstd -C /opt
        ln -s /opt/\${file_prefix}-\${build_type} /opt/llvm-\${build_type}
    done

EOT

# Make and install the llvm.pc file.
ADD make-pkgconfig.sh /tmp
RUN <<EOT bash -ex -o pipefail

    export PATH="/opt/llvm-${HYLO_LLVM_BUILD_TYPE}/bin:\$PATH"
    /tmp/make-pkgconfig.sh /usr/local/lib/pkgconfig/llvm.pc > /dev/null
    rm /tmp/make-pkgconfig.sh

EOT
