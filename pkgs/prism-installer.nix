{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.nix
    pkgs.nixos-install-tools
    pkgs.parted
    pkgs.util-linux
    pkgs.dosfstools
    pkgs.e2fsprogs
  ];
in
writeShellScriptBin "prism-installer" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # --- 1. INTRO & DETECTION ---
    clear
    gum style --border double --margin "1 2" --padding "2 4" --align center --foreground 212 "PRISM OS INSTALLER"
    
    if [ -d /sys/firmware/efi/efivars ]; then
        BOOT_MODE="uefi"
        echo "System is booted in UEFI mode."
    else
        BOOT_MODE="legacy"
        echo "System is booted in Legacy BIOS mode."
    fi
    sleep 1

    # --- 2. PARTITIONING ---
    
    if mountpoint -q /mnt; then
      echo "Filesystem already mounted at /mnt. Skipping partitioning."
    else
      if gum confirm "Do you want to automatically partition a drive? (WIPES DATA)"; then
         echo "Scanning disks..."
         DISKS=$(lsblk -d -n -o NAME,SIZE,MODEL -e 7,11)
         
         if [ -z "$DISKS" ]; then
           gum style --foreground 196 "Error: No disks found."
           exit 1
         fi
         
         SELECTED_LINE=$(echo "$DISKS" | gum choose --header "Select Drive")
         DISK_NAME=$(echo "$SELECTED_LINE" | awk '{print $1}')
         TARGET_DISK="/dev/$DISK_NAME"
         
         gum style --foreground 196 "WARNING: WIPING $TARGET_DISK"
         if ! gum confirm "Are you sure?"; then exit 1; fi
         
         echo "Partitioning $TARGET_DISK for $BOOT_MODE..."
         wipefs -a "$TARGET_DISK"
         
         if [ "$BOOT_MODE" == "uefi" ]; then
             parted -s "$TARGET_DISK" -- mklabel gpt
             parted -s "$TARGET_DISK" -- mkpart ESP fat32 1MiB 512MiB
             parted -s "$TARGET_DISK" -- set 1 esp on
             parted -s "$TARGET_DISK" -- mkpart primary ext4 512MiB 100%
             
             if [[ "$TARGET_DISK" == *"nvme"* ]]; then
               PART_BOOT="''${TARGET_DISK}p1"
               PART_ROOT="''${TARGET_DISK}p2"
             else
               PART_BOOT="''${TARGET_DISK}1"
               PART_ROOT="''${TARGET_DISK}2"
             fi
             
             mkfs.fat -F 32 -n boot "$PART_BOOT"
             mkfs.ext4 -F -L nixos "$PART_ROOT"
             
             mount "$PART_ROOT" /mnt
             mkdir -p /mnt/boot
             mount "$PART_BOOT" /mnt/boot

         else
             parted -s "$TARGET_DISK" -- mklabel gpt
             parted -s "$TARGET_DISK" -- mkpart non-fs 0% 2MiB
             parted -s "$TARGET_DISK" -- set 1 bios_grub on
             parted -s "$TARGET_DISK" -- mkpart primary ext4 2MiB 100%
             
             if [[ "$TARGET_DISK" == *"nvme"* ]]; then
               PART_ROOT="''${TARGET_DISK}p2"
             else
               PART_ROOT="''${TARGET_DISK}2"
             fi
             
             mkfs.ext4 -F -L nixos "$PART_ROOT"
             mount "$PART_ROOT" /mnt
         fi
         
         gum style --foreground 212 "Partitioning Complete!"
      else
         echo "Please mount partitions manually to /mnt."
         exit 1
      fi
    fi

    # --- 3. ONBOARDING ---
    
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

   # --- 4. GENERATE CONFIG ---
    
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")
    [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" == "null" ] && LATEST_TAG="main"

    TARGET_DIR="/mnt/etc/prism"
    mkdir -p "$TARGET_DIR"

    # Clean up old config
    if [ -d "/mnt/etc/nixos" ]; then rm -rf "/mnt/etc/nixos"; fi

    nixos-generate-config --root /mnt --show-hardware-config > "$TARGET_DIR/hardware-configuration.nix"

    BOOT_DEVICE_CONFIG=""
    if [ "$BOOT_MODE" == "legacy" ] && [ -n "$TARGET_DISK" ]; then
        BOOT_DEVICE_CONFIG="prism.hardware.boot.device = \"$TARGET_DISK\";"
    fi

    # 4a. Generate users.nix (Modular User Config)
    # We use markers (# --- USER: name ---) so prism-users can parse/edit this file easily.
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

    # 4b. Generate flake.nix (Imports users.nix)
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
      nixosConfigurations."$HOSTNAME" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./users.nix # Import the dynamic user file
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

    # --- 5. INSTALL ---
    
    if gum confirm "Start Installation? (Tag: $LATEST_TAG)"; then
        gum spin --title "Generating flake.lock..." -- bash -c "cd $TARGET_DIR && nix flake lock --extra-experimental-features 'nix-command flakes'"
        nixos-install --flake "$TARGET_DIR#$HOSTNAME" --no-root-passwd
        
        echo "Setting permissions on /etc/prism..."
        chown -R 1000:users "$TARGET_DIR"
        
        if gum confirm "Reboot now?"; then reboot; fi
    fi
''
