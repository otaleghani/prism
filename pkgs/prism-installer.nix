{ pkgs, writeShellScriptBin }:

let
  # Import sub-modules
  partitionScript = pkgs.callPackage ./installer/partition.nix { };
  generateScript = pkgs.callPackage ./installer/generate.nix { };

  deps = [
    pkgs.gum
    pkgs.nix
    pkgs.nixos-install-tools
    partitionScript
    generateScript
  ];
in
writeShellScriptBin "prism-installer" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # State file for passing variables between steps
    STATE_FILE="/tmp/prism-install.env"
    rm -f "$STATE_FILE"
    touch "$STATE_FILE"

    # INTRO 
    clear
    gum style \
  	--border double \
  	--margin "1 2" \
  	--padding "2 4" \
  	--align center \
  	--foreground 212 "PRISM OS INSTALLER"

    # PARTITIONING 
    # Runs the partitioning wizard (pkgs/installer/partition.nix)
    # Writes BOOT_MODE and TARGET_DISK to STATE_FILE
    prism-installer-partition "$STATE_FILE"

    # Load state variables (BOOT_MODE, etc.)
    source "$STATE_FILE"

    # GENERATE CONFIG 
    # Runs the configuration wizard (pkgs/installer/generate.nix)
    # Writes HOSTNAME and LATEST_TAG to STATE_FILE
    prism-installer-generate "$STATE_FILE"
    
    source "$STATE_FILE"

    # INSTALL 
    echo ""
    gum style --foreground 212 "Configuration Ready!"
    echo "Target: $HOSTNAME"
    echo "Version: $LATEST_TAG"
    echo ""

    if gum confirm "Start Installation? (This will install NixOS)"; then
        TARGET_DIR="/mnt/etc/prism"
        
        # Generate lockfile in the chroot environment to avoid install crashes
        gum spin --title "Generating flake.lock..." -- bash -c "cd $TARGET_DIR && nix flake lock --extra-experimental-features 'nix-command flakes'"
        
        # Run the actual install
        nixos-install --flake "$TARGET_DIR#$HOSTNAME" --no-root-passwd
        
        # Ownership Fix
        echo "Setting permissions on /etc/prism..."
        chown -R 1000:users "$TARGET_DIR"
        
        if gum confirm "Reboot now?"; then
            reboot
        fi
    else
        echo "Installation aborted."
        exit 0
    fi
''
