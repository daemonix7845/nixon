# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:
let
  # These variable names are used by Aegis backend
  version = "unstable"; #or 24.05
  username = "daymon";
  hashed = "$6$v1wT3oC4pH/VnUp0$zDdKM5ufnNCUBdPdRGahl/JVGP0aCwvVpS.0TxD.u4fFldTm7jBNcrJpuQenky5MDeWU7TDXv0E1FkhoEGYiV.";
  hashedRoot = "$6$ZYifSxuR8h7aQ1Or$s6w37djq4DzeUU7cn7mFyIMKM/DPXV21A5N8mtJvyl73T8NnN9EDRlZYuLEXILWxgM/j3ocZCiUpyyZM5G1zC0";
  hostname = "daymon";
  theme = "akame";
  desktop = "cinnamon";
  dmanager = "gdm";
  mainShell = "zsh";
  terminal = "kitty";
  browser = "firefox";
  bootloader = if builtins.pathExists "/sys/firmware/efi" then "systemd" else "grub";
  hm-version = if version == "unstable" then "master" else "release-"version; # "master" or "release-24.05"; # Correspond to home-manager GitHub branches
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/${hm-version}.tar.gz";
in
{
  imports = [ # Include the results of the hardware scan.
    {
      athena = {
        inherit bootloader terminal theme mainShell browser;
        enable = true;
        homeManagerUser = username;
        baseConfiguration = true;
        baseSoftware = true;
        baseLocale = true;
        desktopManager = desktop;
        displayManager = dmanager;
      };
    }
   (import "${home-manager}/nixos")
    ./hardware-configuration.nix
    ./nixos-manager/services.nix
    ./nixos-manager/packages.nix
    ./.

     (let
        module = fetchTarball {
          name = "source";
          url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
          sha256 = "sha256-DN5/166jhiiAW0Uw6nueXaGTueVxhfZISAkoxasmz/g=";
        };
        lixSrc = fetchTarball {
          name = "source";
          url = "https://git.lix.systems/lix-project/lix/archive/2.91.1.tar.gz";
          sha256 = "sha256-hiGtfzxFkDc9TSYsb96Whg0vnqBVV7CUxyscZNhed0U=";
        };
        # This is the core of the code you need; it is an exercise to the
        # reader to write the sources in a nicer way, or by using npins or
        # similar pinning tools.
        in import "${module}/module.nix" { lix = lixSrc; }
      )
  ];

  users = lib.mkIf config.athena.enable {
    mutableUsers = true;
    extraUsers.root.hashedPassword = "${hashedRoot}";
    users.${config.athena.homeManagerUser} = {
      shell = pkgs.${config.athena.mainShell};
      isNormalUser = true;
      hashedPassword = "${hashed}";
      extraGroups = [ "wheel" "input" "video" "render" "networkmanager" ];
    };
  };

  networking = {
    hostName = "${hostname}";
    enableIPv6 = false;
  };

 
  services.flatpak.enable = true;

  cyber = {
    enable = true;
    role = "student";
  };
}
