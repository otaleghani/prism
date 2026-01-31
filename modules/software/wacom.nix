{
  config,
  lib,
  ...
}:

let
  allUsers = lib.attrValues config.prism.users;
  hasCreatorProfile = lib.any (user: user.profileType == "creator") allUsers;
in
{
  config = lib.mkIf hasCreatorProfile {
    # Enable Wacom tablet drivers
    hardware.opentabletdriver.enable = true;

    # Or standard wacom drivers if opentabletdriver causes issues:
    # services.xserver.wacom.enable = true;
  };
}
