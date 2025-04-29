{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay, ... }:
    let
      inherit (nixpkgs) lib;

      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;

        overlays = [
          rust-overlay.overlays.default
        ];
      });
    in
    {
      overlays.default = final: prev: {
        nix-minecraft-plugin-upgrade = self.packages.${final.stdenv.system}.nix-minecraft-plugin-upgrade;
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          nightly-rust = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
        in
        rec {
          nix-minecraft-plugin-upgrade = default;
          default = pkgs.callPackage ./build.nix { nightly-rust = nightly-rust; };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nightly-rust
              openssl
              pkg-config
            ];
          };
        });
    };
}
