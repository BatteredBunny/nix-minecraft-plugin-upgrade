{ pkgs, makeRustPlatform, lib, nightly-rust }:
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

  meta = with lib; {
    description = "Basic program that generates list of plugin versions that can be used with nix-minecraft";
    mainProgram = "nix-minecraft-plugin-upgrade";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
