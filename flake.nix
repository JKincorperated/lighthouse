{
  description = "An open-source Ethereum consensus client, written in Rust and maintained by Sigma Prime.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url  = "github:numtide/flake-utils";
    cargo2nix.url = "github:cargo2nix/cargo2nix";
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
      }
    );
    
}
