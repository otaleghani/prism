{ pkgs, ... }:
{
  fonts = {
    # Install a standard set of fonts
    packages = with pkgs; [
      # Standard fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Nerd Fonts (Required for Starship, Waybar, etc.)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only # Great fallback for glyphs
    ];

    # Set default fonts for applications
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
