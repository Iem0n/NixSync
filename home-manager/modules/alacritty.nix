{lib, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        dynamic_padding = true;
        opacity = 0.96;
        decorations = "none";
      };

      font = {
        size = 12.0;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "Always";
        };
      };

      colors = {
        primary = {
          background = "#111214";
          foreground = "#c5c8c6";
        };

        normal = {
          black   = "#1d1f21";
          red     = "#e67e80";
          green   = "#b5bd68";
          yellow  = "#f0c674";
          blue    = "#81a2be";
          magenta = "#b294bb";
          cyan    = "#81beb7";
          white   = "#c5c8c6";
        };

        cursor = {
          text = "#1d1f21";
          cursor = "#ffffff";
        };

        selection = {
          text = "#ffffff";
          background = "#282a2e";
        };
      };
    };
  };
}
