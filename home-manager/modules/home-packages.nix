{ pkgs, ... }: {
  home.packages = with pkgs; [
    anki
    obsidian
    telegram-desktop
    ffmpeg
    btop
    brightnessctl
    unzip
    zip
    libnotify
    spotify
    zenity
    (atlauncher.override { jre = openjdk17; })
  ];
}
