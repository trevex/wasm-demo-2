{
  description = "wasm-demo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }@inputs:
    let
      overlays = [ (import rust-overlay) ];
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
      in
      with pkgs; rec {
        devShell = mkShell rec {
          name = "wasm-demo";

          nativeBuildInputs = [ pkg-config ];

          buildInputs = [
            ((rust-bin.selectLatestNightlyWith
              (toolchain: toolchain.default)).override {
              targets = [ "wasm32-wasi" ];
            })
            rust-analyzer
            buildah
            podman
            wasmedge
            (crun.overrideAttrs (prev: {
              configureFlags = [ "--with-wasmedge" ];
              buildInputs = prev.buildInputs ++ [ wasmedge ];
              postFixup =
                let
                  libPath = lib.makeLibraryPath [ wasmedge systemd libseccomp libcap criu yajl ];
                in
                ''
                  patchelf \
                    --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                    --set-rpath "${libPath}" \
                    $out/bin/crun
                '';
            }))
          ];

          # LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        };
      }
    );
}
