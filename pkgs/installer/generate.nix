{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.nixos-install-tools
  ];
in
writeShellScriptBin "prism-installer-generate" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH
    STATE_FILE="$1"
    source "$STATE_FILE"

    # QUESTIONS 
    HOSTNAME=$(gum input --placeholder "prism-pc" --header "Hostname")
    [ -z "$HOSTNAME" ] && HOSTNAME="prism-pc"

    USERNAME=$(gum input --placeholder "user" --header "Username")
    [ -z "$USERNAME" ] && exit 1
    
    FULLNAME=$(gum input --placeholder "Full Name" --header "Full Name")
    [ -z "$FULLNAME" ] && FULLNAME="Prism User"

    PASSWORD=$(gum input --password --placeholder "Password" --header "Password")
    [ -z "$PASSWORD" ] && exit 1

    PROFILE=$(gum choose "dev" "gamer" "creator" "pentester" "custom")
    GPU=$(gum choose "nvidia" "amd" "intel" "vm" "none")

    # GENERATION 
    echo "Fetching Prism..."
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")
    [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ] && LATEST_TAG="main"

    TARGET_DIR="/mnt/etc/prism"
    mkdir -p "$TARGET_DIR"

    # Cleanup old config
    if [ -d "/mnt/etc/nixos" ]; then
        echo "Cleaning up old /etc/nixos..."
        rm -rf "/mnt/etc/nixos"
    fi

    gum spin --title "Generating hardware config..." -- \
      nixos-generate-config --root /mnt --show-hardware-config > "$TARGET_DIR/hardware-configuration.nix"

    BOOT_DEVICE_CONFIG=""
    if [ "$BOOT_MODE" == "legacy" ] && [ -n "$TARGET_DISK" ]; then
        BOOT_DEVICE_CONFIG="prism.hardware.boot.device = \"$TARGET_DISK\";"
    fi

    # Generate users.nix
    cat > "$TARGET_DIR/users.nix" <<EOF
  { pkgs, ... }: {
    # --- USER: $USERNAME ---
    prism.users.$USERNAME = {
      description = "$FULLNAME";
      profileType = "$PROFILE";
      isNormalUser = true;
      initialPassword = "$PASSWORD";
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    };
    # --- END USER: $USERNAME ---
  }
  EOF

    # Generate flake.nix
    cat > "$TARGET_DIR/flake.nix" <<EOF
  {
    description = "PrismOS System Config";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      prism.url = "github:otaleghani/prism/$LATEST_TAG";
      prism.inputs.nixpkgs.follows = "nixpkgs";
      silentSDDM.url = "github:uiriansan/SilentSDDM";
      silentSDDM.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, prism, silentSDDM, ... }@inputs: {
      nixosConfigurations.prism = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./users.nix
          prism.nixosModules.default
          silentSDDM.nixosModules.default

          ({ pkgs, ... }: {
            networking.hostName = "$HOSTNAME";
            system.stateVersion = "24.05";

            prism.hardware.gpu = "$GPU";
            
            prism.hardware.boot.mode = "$BOOT_MODE";
            $BOOT_DEVICE_CONFIG
          })
        ];
      };
    };
  }
  EOF

    # Export variables to state file for the final install step
    echo "HOSTNAME=$HOSTNAME" >> "$STATE_FILE"
    echo "LATEST_TAG=$LATEST_TAG" >> "$STATE_FILE"
''
