{ pkgs, ... }: {
  services.mako = {
    enable = true;
    
    # Теперь все базовые параметры упаковываются в один структурированный сет settings.
    # Больше никакого camelCase — пишем ключи через дефис, как в оригинальном конфиге Mako!
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = "#1d1f21dd";
      text-color = "#ffffffff";
      border-size = 2;
      border-color = "#333333ff";
      border-radius = 10;
      progress-color = "#282a2eff";
      
      padding = "15";
      margin = "10";
      default-timeout = 5000;
    };

    # Твои специфичные алерты для критических уведомлений остаются тут
    extraConfig = ''
      [urgency=high]
      border-color=#e67e80ff
      text-color=#e67e80ff
    '';
  };
}
