ARG SWIFT_VERSION=5.9

FROM swift:${SWIFT_VERSION}

ARG HYLO_LLVM_BUILD_RELEASE=2024-02-29-r2
ARG LLVM_VERSION=17.0.6

ENV HYLO_LLVM_DOWNLOAD_URL="https://github.com/hylo-lang/llvm-build/releases/download"

RUN apt-get clean
RUN apt-get update
RUN apt-get install -y tar zstd libzstd1 libzstd-dev curl

RUN <<EOT bash
set -e
set -o pipefail

file_prefix="llvm-\${LLVM_VERSION}-\$(uname -m)-unknown-linux-gnu"
url_prefix="\${HYLO_LLVM_DOWNLOAD_URL}/\${HYLO_LLVM_BUILD_RELEASE}/\$file_prefix"

for build_type in Debug MinSizeRel; do
  curl -L "\${url_prefix}-\${build_type}.tar.zst" | tar -x --zstd -C /opt
  ln -s /opt/\${file_prefix}-\${build_type} /opt/llvm-\${build_type}
done
EOT
