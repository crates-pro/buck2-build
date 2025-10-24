FROM almalinux:9.6-20250909

# Install build dependencies
# cc (crates.io): clang
# cmake (crates.io): cmake
# libgit2-sys (crates.io): libgit2 libgit2-devel
# {openssl, openssl-sys, libssh2-sys} (crates.io): openssl-devel
RUN dnf update -y \
    && dnf group install -y "Development Tools" \
    && dnf install -y epel-release glibc-langpack-en sudo tzdata \
    && dnf install -y clang cmake libgit2 libgit2-devel openssl-devel \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# Set timezone and locale
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Set library environment variables
ENV LD_LIBRARY_PATH="/usr/local/lib64:/usr/lib64" \
    PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig"

# Create and switch to user
ARG USERNAME="rust"
ARG USER_UID="1000"
RUN useradd -m -s /bin/bash -u $USER_UID $USERNAME \
    && mkdir -p /etc/sudoers.d \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
