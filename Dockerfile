FROM docker.io/rust:1.67 AS build
RUN rustup target add wasm32-wasi
WORKDIR /wasm-demo
COPY Cargo.toml .
COPY Cargo.lock .
COPY src/ src/
RUN cargo build --target wasm32-wasi --release

FROM scratch
ENTRYPOINT [ "wasm-demo.wasm" ]
COPY --from=build /wasm-demo/target/wasm32-wasi/release/wasm-demo.wasm wasm-demo.wasm
