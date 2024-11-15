{ pkgs, makeRustPlatform, nightly-rust }:
let
  platform = makeRustPlatform {
    cargo = nightly-rust;
    rustc = nightly-rust;
  };
in
platform.buildRustPackage {
  name = "nix-minecraft-plugin-upgrade";
  cargoLock.lockFile = ./Cargo.lock;

  src = ./.;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];


  buildInputs = with pkgs; [
    openssl
  ];
}
