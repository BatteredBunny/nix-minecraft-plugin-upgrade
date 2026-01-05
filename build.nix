{
  pkgs,
  lib ? pkgs.lib,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  name = "nix-minecraft-plugin-upgrade";
  version = "0.2.2";

  cargoLock.lockFile = ./Cargo.lock;

  src = ./.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "Basic program that generates list of plugin versions that can be used with nix-minecraft";
    mainProgram = "nix-minecraft-plugin-upgrade";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
