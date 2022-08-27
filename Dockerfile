FROM rust:latest as builder

# Make a fake Rust app to keep a cached layer of compiled crates
RUN USER=root cargo new app
WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
# Needs at least a main.rs file with a main function
RUN mkdir src && echo "fn main(){}" > src/main.rs
# Will build all dependent crates in release mode
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/src/app/target \
    cargo build --release
COPY . .
RUN cargo install --path .

FROM debian:bullseye-slim
RUN useradd -ms /bin/bash app
USER app
WORKDIR /app
# Get compiled binaries from builder's cargo install directory
COPY --from=builder /usr/local/cargo/bin/warp-example /app/warp-example
EXPOSE 3030
