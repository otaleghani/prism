Dotfiles, how the override system works, [[17 prism-save]]

# Configuration

The configuration resides in the ~/.config/prism directory.

The default config is just a flake.nix file, a flake.lock file and that's it. Nothing more.

# Overrides

## Dotfiles
The user can use the `prism-save` command to save the overrides into the correct folder. This will save the dotfiles in subsequential updates, which works like `git`: you track files using `prism-save <file>`. This saves the file names into a `.prismsave` file and saves them in the overrides.

You can delete tracked files using `prism-save delete <file>`.

## Themes and wallpapers
Users need to add into the prism configuration the overrides for their user.
For themes the folder is `/etc/prism/overrides/USERNAME/themes`
For wallpapers the folder is `/etc/prism/overrides/USERNAME/wallpapers`
