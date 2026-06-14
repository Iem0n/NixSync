{config, pkgs, ... }: {
  imports = [
    ./modules
  ];
  
  home.username = "vova";
  home.homeDirectory = "/home/vova";
  home.stateVersion = "26.05";

  programs.bash = {
    enable = true;
  };
}
