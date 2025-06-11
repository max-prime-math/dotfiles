if status is-interactive
    # Commands to run in interactive sessions can go here
end
# ~/.config/fish/config.fish

fastfetch

export GDK_BACKEND=x11
export LIBGL_ALWAYS_SOFTWARE=1

starship init fish | source
