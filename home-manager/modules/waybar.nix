{ pkgs, ... }: 

let
  # Декларативно оборачиваем твои bash-скрипты. 
  # Nix сам добавит их в Store, сделает исполняемыми (chmod +x) и даст к ним путь.
  fuzzel-audio = pkgs.writeScriptBin "fuzzel-audio.sh" ''
    #!/usr/bin/env bash
    devices=$(${pkgs.wireplumber}/bin/wpctl status | awk '/Sinks:/ {flag=1; next} /Sources:/ {flag=0} flag' | grep -E '[0-9]+\.' | sed 's/^[[:space:]]*//')
    if [ -z "$devices" ]; then
        ${pkgs.libnotify}/bin/notify-send "Ошибка" "Аудиоустройства не найдены"
        exit 1
    fi
    selected=$(echo "$devices" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -i -p "󰓃 Аудио:")
    if [ ! -z "$selected" ]; then
        node_id=$(echo "$selected" | awk '{print $1}' | tr -d '.')
        ${pkgs.wireplumber}/bin/wpctl set-default "$node_id"
        dev_name=$(echo "$selected" | cut -d'.' -f2- | sed 's/^[[:space:]]*//')
        ${pkgs.libnotify}/bin/notify-send "Аудио" "Выход изменен на: $dev_name"
    fi
  '';

  fuzzel-wifi = pkgs.writeScriptBin "fuzzel-wifi.sh" ''
    #!${pkgs.runtimeShell}
    
    # Сначала вытягиваем отдельно активную сеть, если она есть
    active_ssid=''$( ${pkgs.networkmanager}/bin/nmcli --terse --fields IN-USE,SSID device wifi list | grep "^*:" | cut -d':' -f2 )
    
    # Получаем список остальных сетей (исключая активную, чтобы не дублировать)
    raw_list=''$( ${pkgs.networkmanager}/bin/nmcli --terse --fields SSID,SECURITY device wifi list | grep -v "^BSSID" )
    
    # Формируем финальный список для меню
    formatted_list=""
    if [ ! -z "''$active_ssid" ]; then
        formatted_list="󰖩  ''$active_ssid   [CONNECTED]""\n"
    fi
    
    # Добавляем остальные сети, убирая дубликаты и пустые строки
    other_networks=''$(echo "''$raw_list" | grep -v "^:" | grep -w -v "''$active_ssid" | sed 's/:/  │  /g' | sort -u)
    formatted_list="''${formatted_list}''${other_networks}"
    
    # Вызываем fuzzel
    selected_node=''$(echo -e "''$formatted_list" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -i -p "󰖩 Сети:")
    
    if [ -z "''$selected_node" ]; then
        exit 0
    fi

    # Если кликнули на уже подключенную сеть — ничего не делаем
    if [[ "''$selected_node" == *"[CONNECTED]"* ]]; then
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Вы уже подключены к этой сети"
        exit 0
    fi

    # Вытаскиваем чистый SSID для подключения
    ssid=''$(echo "''$selected_node" | awk -F '  │  ' '{print ''$1}' | sed 's/[[:space:]]*$//')

    # Проверяем сохраненные профили
    is_saved=''$( ${pkgs.networkmanager}/bin/nmcli connection show | grep -w "''$ssid" )

    if [ ! -z "''$is_saved" ]; then
        ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Подключение к ''$ssid..."
        ${pkgs.networkmanager}/bin/nmcli connection up id "''$ssid"
    else
        # Запрос пароля для защищенных сетей
        if [[ "''$selected_node" == *"WPA"* || "''$selected_node" == *"WEP"* ]]; then
            pass=''$( ${pkgs.fuzzel}/bin/fuzzel --dmenu --password -p "Пароль для ''$ssid:" )
            if [ ! -z "''$pass" ]; then
                ${pkgs.libnotify}/bin/notify-send "Wi-Fi" "Подключение к новой сети ''$ssid..."
                ${pkgs.networkmanager}/bin/nmcli device wifi connect "''$ssid" password "''$pass"
            fi
        else
            ${pkgs.networkmanager}/bin/nmcli device wifi connect "''$ssid"
        fi
    fi
  '';

in {
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 18;
        spacing = 2;
        margin = "0";
        
        modules-left = [ "niri/workspaces" "temperature" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "wireplumber#sink" "network" "battery" "group/session" ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "󰮯";
            default = "◇";
            urgent = "󰀨";
          };
        };

        clock = {
          format = "{:%H:%M %d %b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        temperature = {
          thermal-zone = 0;
          critical-threshold = 80;
          format = "{temperatureC}°C";
          format-critical = "{temperatureC}°C";
          interval = 2;
        };

        tray = {
          icon-size = 13;
          spacing = 8;
        };

        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄";
          format-plugged = "󰚥";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "󰖩";
          format-ethernet = "󰈀";
          format-disconnected = "󰖪";
          tooltip-format = "{essid}";
          # Динамически подставляем путь к сгенерированному скрипту в Nix Store!
          on-click = "${fuzzel-wifi}/bin/fuzzel-wifi.sh";
        };

        "wireplumber#sink" = {
          format = "{icon}";
          format-muted = "";
          format-icons = [ "" "" "" ];
          on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
          on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
          # Динамически подставляем путь к скрипту аудио-меню
          on-click-right = "${fuzzel-audio}/bin/fuzzel-audio.sh";
        };

        "group/session" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 300;
            transition-left-to-right = false;
          };
          modules = [ "custom/power" "custom/reboot" "custom/logout" ];
        };

        "custom/power" = {
          format = " ";
          on-click = "systemctl poweroff";
          tooltip-format = "Power Off";
        };

        "custom/reboot" = {
          format = "  ";
          on-click = "systemctl reboot";
          tooltip-format = "Reboot";
        };

        "custom/logout" = {
          format = " 󰈆 ";
          on-click = "${pkgs.niri}/bin/niri msg action quit";
          tooltip-format = "Logout (Exit Niri)";
        };
      };
    };

    # Твой style.css один в один
    style = ''
      @define-color background #1d1f21;
      @define-color background-light #282a2e;
      @define-color foreground #e0e0e0;
      @define-color white #ffffff;
      @define-color muted #555555;
      @define-color alert #e67e80;

      @define-color workspaces-focused-fg @white;
      @define-color workspaces-urgent-bg @alert;
      @define-color workspaces-urgent-fg @background;

      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font Propo";
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background-color: @background;
          color: @foreground;
      }

      #workspaces, #temperature, #clock, #network, #wireplumber, #battery, #tray, #group-session {
          padding: 0 6px;
          margin: 0;
          background-color: transparent;
      }

      #workspaces button {
          padding: 0 4px;
          background-color: transparent;
          color: @muted;
      }

      #workspaces button:hover {
          background: @background-light;
          color: @foreground;
      }

      #workspaces button.focused {
          box-shadow: inset 0 -2px @workspaces-focused-fg;
          color: @workspaces-focused-fg;
          font-weight: bold;
      }

      #clock { color: @white; }
      #temperature, #battery { color: @foreground; }
      #temperature.critical { color: @alert; }
      #battery.charging, #battery.plugged { color: @white; }
      #battery.critical:not(.charging) { color: @alert; }
      #network.disconnected, #wireplumber.muted { color: @muted; }

      #custom-power, #custom-reboot, #custom-logout {
          padding: 0 6px;
          color: @foreground;
      }

      #custom-power:hover, #custom-reboot:hover, #custom-logout:hover {
          background-color: @background-light;
      }

      #custom-power:hover { color: @alert; }
    '';
  };
}
