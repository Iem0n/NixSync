{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./modules
    ];

  # loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # network
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  #time & locale
  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  # user cofiguration
  users.users.vova = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm"]; 
    packages = with pkgs; [
      tree
    ];
  };

  networking.localCommands = ''
  # Отключаем STP, чтобы мост не блокировал трафик при пересчете маршрутов
  ${pkgs.bridge-utils}/bin/brctl stp virbr0 off || true
  # Выставляем задержку пересылки в ноль
  ${pkgs.bridge-utils}/bin/brctl setfd virbr0 0 || true
'';
  
  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.docker.enable = true;
  
  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];

  # latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 
  nixpkgs.config.allowUnfree = true;

  # services 
  services.openssh.enable = true;

  system.stateVersion = "26.05";
}

