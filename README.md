# dotfiles

Personal config for a Hyprland/Wayland setup on Arch Linux (running under WSL2 for some tools).

## What's here

| Path | Tool |
|------|------|
| `.config/fish/` | Fish shell + starship prompt |
| `.config/hypr/` | Hyprland WM, hypridle, hyprlock |
| `.config/waybar/` | Status bar |
| `.config/nvim/init.vim` | Neovim (vim-plug) |
| `.config/ghostty/` | Ghostty terminal |
| `.config/zellij/` | Zellij terminal multiplexer |
| `.config/starship.toml` | Starship prompt config |
| `.config/btop/` | btop resource monitor |
| `.config/tofi/` | tofi launcher |
| `.config/wlogout/` | wlogout session menu |
| `.config/zathura/` | Zathura PDF viewer |
| `.config/kmonad/` | KMonad keyboard remapping |
| `.config/qt6ct/` | Qt6 theming |

## Setup

Clone and symlink (or use [GNU stow](https://www.gnu.org/software/stow/)):

```sh
git clone https://github.com/<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ .
```

### Neovim plugins

Install [vim-plug](https://github.com/junegunn/vim-plug#neovim), then open nvim and run:

```
:PlugInstall
```
