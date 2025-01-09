{
  description = "An open-source Ethereum consensus client, written in Rust and maintained by Sigma Prime.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-compat, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            cmake
            openssl
            clang
            llvmPackages.libclang
            llvmPackages.libcxxClang
            pkg-config
            rust-bin.stable.latest.default
            postgresql
            
            # QOL
            rust-analyzer
            rustfmt
            clippy
          ];

          LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";
        };

        packages.default = with pkgs; rustPlatform.buildRustPackage {
          pname = "lighthouse";
          version = if (self ? rev) then self.rev else self.dirtyRev;

          src = ./.;

          cargoLock.lockFile = ./Cargo.lock;
          cargoLock.outputHashes = {
            "libmdbx-0.1.4" = "sha256-ONp4uPkVCN84MObjXorCZuSjnM6uFSMXK1vdJiX074o=";
            "lmdb-rkv-0.14.0" = "sha256-sxmguwqqcyOlfXOZogVz1OLxfJPo+Q0+UjkROkbbOCk=";
            "quick-protobuf-0.8.1" = "sha256-dgePLYCeoEZz5DGaLifhf3gEIPaL7XB0QT9wRKY8LJg=";
            "xdelta3-0.1.5" = "sha256-3ZZ2SDaOT8IOymgJaBCh9GNU5wpYgZnb51kN5sMsFLk=";
          };

          useFetchCargoVendor = true;

          doCheck = true;
          singleStep = true;

          nativeBuildInputs = [
            cmake
            pkg-config
            clang
            llvmPackages.libclang
          ];

          buildInputs = [
            openssl
            postgresql
          ];

          LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";

          meta = with lib; {
            description = "An open-source Ethereum consensus client, written in Rust";
            homepage = "https://lighthouse.sigmaprime.io/";
            license = licenses.asl20;
            maintainers = with maintainers; [];
          };
        };
      }
    );
}
