{ pkgs, ... }: {
  home.packages = [ pkgs.swaybg ];

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Swaybg wallpaper daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Restart = "on-failure";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${./wallpapers/mountains.png}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
