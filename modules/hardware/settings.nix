{ lib, ... }:
{
  nix.settings = {
    # Enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Save space by optimizing the store automatically
    auto-optimise-store = lib.mkDefault true;

    # Allow unfree packages (like Spotify, Discord, Nvidia drivers)
    # This is almost always desired in a desktop distro
    allowUnfree = lib.mkDefault true;
  };
}
