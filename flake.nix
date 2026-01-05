{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
        }
      );
    in
    {
      overlays.default = final: prev: {
        nix-minecraft-plugin-upgrade = self.packages.${final.stdenv.system}.nix-minecraft-plugin-upgrade;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          nix-minecraft-plugin-upgrade = default;
          default = pkgs.callPackage ./build.nix { };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustc
              cargo
              openssl
              pkg-config
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          package = pkgs.callPackage ./build.nix { };
        }
      );
    };
}
