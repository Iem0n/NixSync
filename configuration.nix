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
    extraGroups = [ "wheel" "networkmanager" "docker" ]; 
    packages = with pkgs; [
      tree
    ];
  };

  programs.niri.enable = true;
  programs.firefox.enable = true;
  programs.dconf.enable = true;

  # Включаем виртуализацию
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Добавляем твоего пользователя в нужные группы (чтобы запускать без sudo)
  users.users.vova.extraGroups = [ "libvirtd" "kvm" ];

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

