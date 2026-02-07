export EDITOR=nvim
eval "$(ssh-agent -s)" >/dev/null 2>&1

export COLORTERM="truecolor"

bindkey "^f" autosuggest-accept
bindkey "^e" autosuggest-execute
bindkey "^c" autosuggest-clear
bindkey "^w" autosuggest-fetch

# --- Prism Theme Integration ---
if [ -f "$HOME/.local/share/prism/current/fzf.sh" ]; then
    source "$HOME/.local/share/prism/current/fzf.sh"
fi
