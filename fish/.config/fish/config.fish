# these will only apply to launched shells

# ========================
# local config overwrite
# ========================
set -l local_config ~/.config/fish/config.local.fish
if test -f $local_config
    source $local_config
end

