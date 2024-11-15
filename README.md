# nix-minecraft-plugin-upgrade

Basic program that generates list of plugin versions that can be used with [nix-minecraft](https://github.com/Infinidoge/nix-minecraft)

Personally i use it on my server to automate upgrading the plugins used

## Example usage with nix-minecraft

```sh
nix run github:BatteredBunny/nix-minecraft-plugin-upgrade -- --loader paper --game-version 1.21.1 --project simple-voice-chat --project worldedit > paper-vanilla-plugins.nix
```

Example command output

```nix
# auto generated with nix-minecraft-plugin-upgrade --loader paper --game-version 1.21.1 --project simple-voice-chat --project worldedit
{ pkgs, ... }: {
  "plugins/voicechat-bukkit-2.5.25.jar" = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/tA5pALYl/voicechat-bukkit-2.5.25.jar"; sha512 = "b01ac4d92ebe8d4ff848bdea8d4afcff9d600350d9ba86313e715499d4a339aafdf3d1b62261e4cfd7a397f4832c597c54e4b283c48c16e69cf622028d93a96b"; };
  "plugins/worldedit-bukkit-7.3.8.jar" = pkgs.fetchurl { url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/ecqqLKUO/worldedit-bukkit-7.3.8.jar"; sha512 = "ca8c25d1c2d894b7c3293617875abf23af1cb1c0a6a4e142ee514e7d06536a67d91664009ce8f54902c8f4fd05e32f8235f43cf52bfbd0a6c5622d6bef4f1c6e"; };
}
```

```nix
services.minecraft-servers = {
    enable = true;
    eula = true;

    servers.paper-vanilla = {
        enable = true;
        symlinks = import ./paper-vanilla-plugins.nix { inherit pkgs; };
        package = pkgs.paperServers.paper-1_21_1;
    };
};
```