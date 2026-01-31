{ }:
{
  system.activationScripts.createSharedDir = ''
    mkdir -p /home/shared
    chown root:users /home/shared
    chmod 770 /home/shared
  '';
}
