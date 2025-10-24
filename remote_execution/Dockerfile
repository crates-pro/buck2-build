FROM localhost:30500/almalinux:9.6-cratespro-20251023

ARG USERNAME="rust"
USER $USERNAME

# Install Rust with nightly-2025-08-01 toolchain (same as Buck2)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly-2025-08-01 -y
ENV PATH="/home/$USERNAME/.cargo/bin:$PATH"

# Install NativeLink with nightly-2025-05-21 toolchain (as in NativeLink `MODULE.bazel`)
RUN cargo +nightly-2025-05-21 install --git https://github.com/TraceMachina/nativelink.git --rev 1296a3a nativelink

# Create and set permissions for directories
USER root
RUN mkdir -p /workdir && chown $USERNAME:$USERNAME /workdir
RUN mkdir -p /tmp/nativelink && chown $USERNAME:$USERNAME /tmp/nativelink
USER $USERNAME

WORKDIR /workdir

# Download resources required by `//third-party/vendor/utoipa-swagger-ui-9.0.2-patch1/src/lib.rs`
RUN curl -L -o swagger-ui-5.17.14.zip https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip \
    && unzip -j swagger-ui-5.17.14.zip "swagger-ui-5.17.14/dist/*" -d ./swagger-ui-5.17.14-dist \
    && rm -f swagger-ui-5.17.14.zip

COPY basic_cas.json5 .
CMD ["nativelink", "./basic_cas.json5"]
