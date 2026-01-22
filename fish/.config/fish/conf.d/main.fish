# ========================
# environment variables
# ========================

set -x MANROFFOPT -c
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

set -gx KITTY_CONFIG_DIRECTORY ~/.config/kitty
set -gx TERM xterm-256color
set -gx SYSTEMD_EDITOR nvim
set -g fish_color_autosuggestion 666666 # holy hell

# ========================
# source stuff
# ========================

if test -f ~/.fish_profile
    source ~/.fish_profile
end

if test -f $HOME/.cargo/env.fish
    source $HOME/.cargo/env.fish
end

for dir in $HOME/.local/bin $HOME/.cargo/bin $HOME/applications/depot_tools
    if test -d $dir
        fish_add_path $dir
    end
end

function venv 
  if test -e .venv/bin/activate.fish
    source .venv/bin/activate.fish
  end
end

# ========================
# history and key bindings
# ========================

function __history_previous_command
    # !! previous command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i "!"
    end
end

function __history_previous_command_arguments
    # !$ previous command args
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

function history
    # show command history with timestamp
    builtin history --show-time='%F %T '
end

# ========================
# backup and copy
# ========================

function backup --argument filename
    # backup a file
    cp $filename $filename.bak
end

function copy
    if test (count $argv) -eq 2 -a -d $argv[1]
        set from (string trim-right $argv[1] /)
        set to $argv[2]
        rsync -ah --progress $from/ $to/
    else
        rsync -ah --progress $argv[1] $argv[2]
    end
end

# ========================
# system and package management
# ========================

function ec --description "Edit fish config"
    nvim ~/.config/fish/conf.d/main.fish
end

function sc --description "Source fish config"
    source ~/.config/fish/conf.d/main.fish
end

function vim --wraps=nvim --description "Use neovim"
    command nvim $argv
end

function icat --description "Print image in terminal"
    command kitten icat $argv
end

function fixpacman
    # remove pacman lock
    sudo rm /var/lib/pacman/db.lck
end

#function update
#    # update system
#    sudo cachyos-rate-mirrors
#    and sudo pacman -Syu
#end

function update
    set mirror_file ~/.cache/last_mirror_update
    set now (date +%s)
    set threshold 604800 # in seconds

    if test -f $mirror_file
        set last_update (cat $mirror_file)
    else
        set last_update 0
    end

    if test (math $now - $last_update) -gt $threshold
        echo "updating mirror list..."
        sudo cachyos-rate-mirrors
        echo $now >$mirror_file
    else
        echo "mirrors recently updated, skipping..."
    end

    echo "running pacman..."
    sudo pacman -Syu
    echo "updates done!"
end

function mirror
    # refresh mirrors
    sudo cachyos-rate-mirrors
end

function cleanup
    # remove orphan packages
    sudo pacman -Rns (pacman -Qtdq)
end

function jctl
    # show journal errors
    journalctl -p 3 -xb
end

function big
    # list largest packages
    expac -H M '%m\t%n' | sort -h | nl
end

function gitpkg
    # count git packages
    pacman -Q | grep -i "\-git" | wc -l
end

function rip
    # recently installed packages
    expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl
end

# ========================
# file and archive utilities
# ========================

function tarnow
    # create archive
    tar -acf $argv
end

function untar
    # extract archive
    tar -zxvf $argv
end

function wget
    # resume download
    command wget -c $argv
end

# ========================
# navigation shortcuts
# ========================

function ..
    # go up one directory
    cd ..
end

function ...
    # go up two directories
    cd ../..
end

function ....
    # go up three directories
    cd ../../..
end

function .....
    # go up four directories
    cd ../../../..
end

function ......
    # go up five directories
    cd ../../../../..
end

# ========================
# other utilities
# ========================

function dir
    # colorized dir
    dir --color=auto $argv
end

function vdir
    # colorized verbose dir
    command vdir --color=auto $argv
end

function hw
    # hardware info
    hwinfo --short $argv
end

function grep
    # colored grep
    command grep --color=auto $argv
end

function fgrep
    # colored fgrep
    command fgrep --color=auto $argv
end

function egrep
    # colored egrep
    command egrep --color=auto $argv
end

# ========================
# starship prompt
# ========================

if command -q starship
    starship init fish | source
end

# ========================
# window title
# ========================

#function fish_title
#    echo (string join '' (hostname -s) ":" (prompt_pwd))
#end

function fish_title
    set host (hostname -s)
    set cmd (status current-command)
    set dir (prompt_pwd)

    if test "$cmd" = "fish" -o -z "$cmd"
        echo "[$host] $dir"
        return
    end

    echo "[$host] $dir"
end

# ========================
# motd
# ========================

function fish_greeting
    # print user and time
    set_color green
    echo -n "User: "
    set_color cyan
    echo (whoami)

    set_color green
    echo -n "Time: "
    set_color yellow
    echo (date "+%H:%M:%S on %m-%d-%Y")

    set_color normal
end
