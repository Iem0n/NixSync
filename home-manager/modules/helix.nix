{ pkgs, ... }: {
  programs.helix = {
    enable = true;
    
    # Твой config.toml, переведенный в синтаксис Nix
    settings = {
      theme = "my_monochrome";

      editor = {
        line-number = "relative";
        mouse = true;
        bufferline = "multiple";
        color-modes = true;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
        };

        whitespace = {
          render = "all";
          characters = { space = "·"; tab = "→"; };
        };

        indent-guides = {
          render = true;
          character = "│";
        };
      };
    };

    # Твои кастомные темы объявляются прямо здесь!
    # Home Manager сам создаст файл ~/.config/helix/themes/my_monochrome.toml
    themes = {
      my_monochrome = {
        inherits = "base16_transparent";
        
        "ui.linenr" = { fg = "gray"; };
        "ui.linenr.selected" = { fg = "white"; modifiers = [ "bold" ]; };
      };
    };
  };
}
