{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.prism.users;

  # Import the package lists from separate files
  commonPkgs = import ./packages/common.nix { inherit pkgs; };
  devPkgs = import ./packages/developer.nix { inherit pkgs; };
  gamerPkgs = import ./packages/gamer.nix { inherit pkgs; };
  pentesterPkgs = import ./packages/pentester.nix { inherit pkgs; };
  creatorPkgs = import ./packages/creator.nix { inherit pkgs; };

  # Map profile strings to package lists
  profilePackages = {
    dev = devPkgs;
    gamer = gamerPkgs;
    pentester = pentesterPkgs;
    creator = creatorPkgs;
    custom = [ ];
  };
in
{
  config = {
    # Install common packages system-wide
    # These are available to root and all users automatically.
    environment.systemPackages = commonPkgs;

    # Install profile packages per-user
    # We iterate over the users defined in your config and inject
    # only the packages matching their chosen profileType.
    users.users = lib.mapAttrs (name: userCfg: {
      packages = (profilePackages.${userCfg.profileType} or [ ]);
    }) cfg;
  };
}
