```
cargo run
curl localhost:8080/echo -XPOST -d 'Hello!'

cargo build --target wasm32-wasi --release
wasmedge target/wasm32-wasi/release/wasm-demo.wasm
curl localhost:8080/echo -XPOST -d 'Hello!'

podman run --runtime $(which crun) --rm --annotation module.wasm.image/variant=compat-smart docker.io/wasmedge/example-wasi:latest /wasi_example_main.wasm 50000000

buildah build --annotation "module.wasm.image/variant=compat" -t wasm-demo
podman run --runtime $(which crun) --rm -p 8080:8080 localhost/wasm-demo:latest
killall -9 podman
```
