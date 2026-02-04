{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum # TUI Tool
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.nixos-install-tools
  ];
in
writeShellScriptBin "prism-installer" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # PRE-FLIGHT CHECKS
    clear
    echo -e "\n\n"
    gum style \
  	--border double \
  	--margin "1 2" \
  	--padding "2 4" \
  	--align center \
  	--foreground 212 "PRISM OS INSTALLER" "Welcome to the Prism onboarding wizard."

    # Check for /mnt
    if ! mountpoint -q /mnt; then
      gum style --foreground 196 "Error: No partitions mounted at /mnt"
      echo "Please use GParted or cfdisk to partition your drives and mount your root to /mnt."
      echo "Example: mount /dev/nvme0n1p2 /mnt && mkdir /mnt/boot && mount /dev/nvme0n1p1 /mnt/boot"
      exit 1
    fi

    # ONBOARDING (Questions)
    
    # Hostname
    HOSTNAME=$(gum input --placeholder "Hostname (e.g. prism-pc)" --header "Choose a Hostname")
    [ -z "$HOSTNAME" ] && HOSTNAME="prism-pc"

    # User Configuration
    USERNAME=$(gum input --placeholder "Username (e.g. oliviero)" --header "Create your User")
    [ -z "$USERNAME" ] && exit 1
    
    FULLNAME=$(gum input --placeholder "Full Name (e.g. Oliviero Taleghani)" --header "Enter Full Name")
    [ -z "$FULLNAME" ] && FULLNAME="Prism User"

    PASSWORD=$(gum input --password --placeholder "Password" --header "Set User Password")
    [ -z "$PASSWORD" ] && exit 1

    # Profile selection
    gum style --foreground 212 "Select your Persona Profile:"
    PROFILE=$(gum choose "dev" "gamer" "creator" "pentester" "custom")

    # Hardware - GPU
    gum style --foreground 212 "Select Primary GPU (for drivers):"
    GPU=$(gum choose "nvidia" "amd" "intel" "vm" "none")

    # Hardware - Boot
    gum style --foreground 212 "Select Boot Mode:"
    BOOT_MODE=$(gum choose "uefi" "legacy")

    # CLONE & GENERATE 
    
    echo ""
    gum spin --title "Fetching latest Prism release..." -- sleep 2
    
    # Get latest tag
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")
    [ -z "$LATEST_TAG" ] && LATEST_TAG="main" # Fallback

    TARGET_DIR="/mnt/etc/nixos"
    mkdir -p "$TARGET_DIR"

    # Generate Hardware Config
    gum spin --title "Generating hardware-configuration.nix..." -- \
      nixos-generate-config --root /mnt --show-hardware-config > "$TARGET_DIR/hardware-configuration.nix"

    # Generate flake.nix
    # We construct a flake that imports the Prism library from the release tag
    cat > "$TARGET_DIR/flake.nix" <<EOF
  {
    description = "PrismOS System Config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      
      # Import Prism Library (Pinned to Release)
      prism.url = "github:otaleghani/prism/$LATEST_TAG";
      prism.inputs.nixpkgs.follows = "nixpkgs";
      
      # SilentSDDM (Required by Prism Login)
      silentSDDM.url = "github:uiriansan/SilentSDDM";
      silentSDDM.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, prism, silentSDDM, ... }@inputs: {
      nixosConfigurations."$HOSTNAME" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Hardware Config (Generated Local)
          ./hardware-configuration.nix
          
          # 2. Prism Core Library
          prism.nixosModules.default
          silentSDDM.nixosModules.default

          # 3. User Customization
          ({ pkgs, ... }: {
            networking.hostName = "$HOSTNAME";
            system.stateVersion = "24.05";

            # Hardware
            prism.hardware.gpu = "$GPU";
            prism.hardware.boot.mode = "$BOOT_MODE";

            # User
            prism.users.$USERNAME = {
              description = "$FULLNAME";
              profileType = "$PROFILE";
              isNormalUser = true;
              initialPassword = "$PASSWORD";
              extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
            };
          })
        ];
      };
    };
  }
  EOF

    # INSTALLATION 
    
    gum style --foreground 212 --border double --padding "1 2" "Configuration Ready!"
    echo "Target: $HOSTNAME ($PROFILE)"
    echo "Prism Version: $LATEST_TAG"
    echo ""
    
    if gum confirm "Start Installation? (This will wipe system files)"; then
        # Run install
        # --no-root-passwd because we set the user password in the config
        nixos-install --flake "$TARGET_DIR#$HOSTNAME" --no-root-passwd
        
        gum style --foreground 212 "Installation Complete!"
        if gum confirm "Reboot now?"; then
            reboot
        fi
    else
        echo "Installation aborted."
        exit 0
    fi
''
