# dots

My personal Arch Linux configuration — Hyprland window manager scripted in Lua, with a custom Quickshell status bar and notification daemon written in QML. Tokyo Night palette, Iosevka Nerd Font, one config to rule the whole desktop.

![OS](https://img.shields.io/badge/OS-Arch%20Linux-1793D1?style=flat-square)
![WM](https://img.shields.io/badge/WM-Hyprland-00BAF0?style=flat-square)
![Bar](https://img.shields.io/badge/Bar-Quickshell-7aa2f7?style=flat-square)

```sh
git clone https://github.com/DaviLe-git/dots.git ~/dots
cd ~/dots && stow --target="$HOME/.config" hypr
```

## Highlights

- **Hyprland in Lua.** The whole compositor config lives in `hyprland.lua` + small focused modules — real comments, loops and variables instead of a thousand-line config file.
- **A bar written in QML.** Quickshell panels on every monitor: media on the left, clock and workspaces in the center, system pills on the right. Widgets are tiny single-purpose QML files you can rearrange or delete freely.
- **Everything themed from one file.** `quickshell/Theme.qml` holds the Tokyo Night palette, font and spacing metrics — change one value and the whole bar follows.
- **Notifications included.** A standalone Quickshell notification daemon with calendar popup and a built-in todo store.
- **Laptop-ready.** Brightness, volume, battery, bluetooth and media keys bound out of the box — most of them work even while the screen is locked.

## Screens

<!-- Add a screenshot of the desktop + bar here -->

## Environment

| Component | Choice |
| --- | --- |
| OS | Arch Linux |
| WM | Hyprland (Lua config) |
| Shell | Zsh |
| Terminal | Kitty |
| Bar | Quickshell (`shell.qml`) |
| Notifications | Quickshell (`Notifications.qml`) |
| Launcher | Wofi |
| Editor | Neovim / VSCodium |
| Browser | Brave |
| Wallpaper | Hyprpaper |
| Lock screen | Hyprlock |
| Font | Iosevka Nerd Font |

## Structure

```
dots/
├── hypr/
│   ├── hyprland.lua          # entrypoint — loads every module
│   ├── hyprlock.conf         # lock screen
│   ├── start-hyprpaper.sh    # restores the wallpaper at launch
│   ├── modules/              # Hyprland config, one topic per file
│   │   ├── monitors.lua      # outputs and workspaces
│   │   ├── binds.lua         # every keybinding
│   │   ├── autostart.lua     # apps launched with the session
│   │   ├── env.lua           # Wayland / Qt environment variables
│   │   ├── decorations.lua   # borders, blur, shadows, animations
│   │   ├── layout.lua        # dwindle, master and scrolling layouts
│   │   ├── input.lua         # keyboard, touchpad and sensitivity
│   │   ├── misc.lua
│   │   └── windowrules.lua   # rules for specific windows
│   └── quickshell/           # QML bar + notification daemon
│       ├── shell.qml         # top bar, one instance per monitor
│       ├── Notifications.qml # standalone notification daemon
│       ├── Theme.qml         # palette, font and metrics (singleton)
│       ├── sections/         # LeftSection / CenterSection / RightSection
│       ├── widgets/          # Clock, Workspaces, Cpu, Volume, Battery, …
│       └── components/       # Pill, ClickablePill, CalendarPopup, …
└── README.md
```

## The bar

Three sections, composed from independent widgets:

| Section | Widgets |
| --- | --- |
| **Left** | `Media` — current track, playerctl-based |
| **Center** | `Clock`, `Workspaces` — time + Hyprland workspaces |
| **Right** | `Tmux`, `Cpu`, `Volume`, `Battery`, `Bluetooth`, `Network`, `Config` |

Rearranging the bar means moving one line in a section file. Adding a widget means dropping a new `.qml` in `widgets/` and referencing it in a section — Quickshell's `qmldir` files already register everything.

The notification daemon is intentionally separate: autostart runs `qs -p ~/.config/hypr/quickshell/Notifications.qml` as its own process, so the bar can crash without taking notifications down (and vice-versa).

## Keybindings

`SUPER` is the Windows key. Full list lives in `hypr/modules/binds.lua`.

### Apps & session

| Key | Action |
| --- | --- |
| `SUPER + Return` | Open terminal (kitty) |
| `SUPER + Q` | Close active window |
| `SUPER + M` | Exit Hyprland (uses `hyprshutdown` when available) |
| `SUPER + L` | Lock screen (hyprlock) |
| `SUPER + E` | File manager (dolphin) |
| `SUPER + D` | App launcher (wofi) |
| `SUPER + W` | Wallpaper picker |
| `SUPER + F2` / `F3` | Brightness −10% / +10% |

### Windows

| Key | Action |
| --- | --- |
| `SUPER + arrows` | Move focus |
| `SUPER + CTRL + arrows` | Move window |
| `SUPER + SHIFT + arrows` | Resize window (repeats while held) |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Toggle pseudo-tiling |
| `SUPER + J` | Toggle split (dwindle) |
| `SUPER + mouse drag` | Move / resize window with the mouse |

### Workspaces

| Key | Action |
| --- | --- |
| `SUPER + 1…0` | Switch to workspace (10 maps to `0`) |
| `SUPER + CTRL + 1…0` | Move window to workspace |
| `SUPER + S` | Toggle scratchpad workspace (`magic`) |
| `SUPER + scroll` | Cycle through workspaces |

### Media & laptop keys

Work while the screen is locked.

| Key | Action |
| --- | --- |
| `XF86AudioRaise/LowerVolume` | Volume ±5% |
| `XF86AudioMute` / `XF86AudioMicMute` | Mute output / input |
| `XF86MonBrightnessUp/Down` | Screen brightness ±5% |
| `XF86AudioPlay/Pause/Next/Prev` | Media control (playerctl) |
| `SUPER + SHIFT + S` | Screenshot (flameshot, primary monitor) |

## Dependencies

```sh
# Core
sudo pacman -S hyprland kitty wofi dolphin zsh

# Bar, notifications, lock and wallpaper
sudo pacman -S quickshell hyprlock hyprpaper

# Widget helpers used by binds and widgets
sudo pacman -S brightnessctl wireplumber playerctl flameshot network-manager-applet

# Font used by the bar theme
sudo pacman -S ttf-iosevka-nerd
```

## Installation

Clone the repository:

```sh
git clone https://github.com/DaviLe-git/dots.git ~/dots
```

Then pick one way to link the config:

### Option A — GNU Stow (recommended)

```sh
cd ~/dots
stow --target="$HOME/.config" hypr
```

### Option B — Manual symlink

```sh
ln -s ~/dots/hypr ~/.config/hypr
```

Log out and back in (or restart Hyprland) for the session to pick everything up.

## Notes

- The bar expects `qs` (Quickshell) in your `PATH` — autostart launches both the bar and the notification daemon from `modules/autostart.lua`.
- GTK/Qt theming is delegated to `qt6ct` via `env.lua`; set your palette there if you want toolkit apps to match the bar.

## License

Do whatever you want with these files — they're dotfiles. Attribution appreciated, not required.
