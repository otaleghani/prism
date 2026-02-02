eval "$(ssh-agent -s)" >/dev/null 2>&1

export COLORTERM="truecolor"

# --- Prism Theme Integration ---
if [ -f "$HOME/.local/share/prism/current/fzf.sh" ]; then
    source "$HOME/.local/share/prism/current/fzf.sh"
fi
