{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.git
    pkgs.curl
    pkgs.jq
    pkgs.nixos-install-tools
    pkgs.parted
    pkgs.util-linux # lsblk, mount
    pkgs.dosfstools # mkfs.fat
    pkgs.e2fsprogs # mkfs.ext4
  ];
in
writeShellScriptBin "prism-installer" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # --- 1. INTRO ---
    clear
    gum style \
  	--border double \
  	--margin "1 2" \
  	--padding "2 4" \
  	--align center \
  	--foreground 212 "PRISM OS INSTALLER (MINIMAL)" "Welcome to the Prism onboarding wizard."

    # --- 2. PARTITIONING ---
    
    if mountpoint -q /mnt; then
      echo "Filesystem already mounted at /mnt. Skipping partitioning."
    else
      if gum confirm "Do you want to automatically partition a drive? (WIPES DATA)"; then
         # List disks (exclude loops and roms)
         # Format: NAME SIZE MODEL
         echo "Scanning disks..."
         DISKS=$(lsblk -d -n -o NAME,SIZE,MODEL -e 7,11)
         
         if [ -z "$DISKS" ]; then
           gum style --foreground 196 "Error: No disks found."
           exit 1
         fi
         
         SELECTED_LINE=$(echo "$DISKS" | gum choose --header "Select Drive to Install Prism OS")
         DISK_NAME=$(echo "$SELECTED_LINE" | awk '{print $1}')
         TARGET_DISK="/dev/$DISK_NAME"
         
         gum style --foreground 196 "WARNING: THIS WILL WIPE ALL DATA ON $TARGET_DISK"
         if ! gum confirm "Are you absolutely sure?"; then
           echo "Aborted."
           exit 1
         fi
         
         echo "Partitioning $TARGET_DISK..."
         
         # 1. Create GPT Table
         parted -s "$TARGET_DISK" -- mklabel gpt
         
         # 2. Create EFI Partition (512MB)
         parted -s "$TARGET_DISK" -- mkpart ESP fat32 1MiB 512MiB
         parted -s "$TARGET_DISK" -- set 1 esp on
         
         # 3. Create Root Partition (Rest of disk)
         parted -s "$TARGET_DISK" -- mkpart primary ext4 512MiB 100%
         
         # Wait for kernel to register partitions
         sleep 2
         
         # Identify partitions (NVMe uses p1, p2 suffixes, SATA uses 1, 2)
         if [[ "$TARGET_DISK" == *"nvme"* ]]; then
           PART_BOOT="''${TARGET_DISK}p1"
           PART_ROOT="''${TARGET_DISK}p2"
         else
           PART_BOOT="''${TARGET_DISK}1"
           PART_ROOT="''${TARGET_DISK}2"
         fi
         
         echo "Formatting partitions..."
         mkfs.fat -F 32 -n boot "$PART_BOOT"
         mkfs.ext4 -F -L nixos "$PART_ROOT"
         
         echo "Mounting..."
         mount /dev/disk/by-label/nixos /mnt
         mkdir -p /mnt/boot
         mount /dev/disk/by-label/boot /mnt/boot
         
         gum style --foreground 212 "Partitioning Complete!"
      else
         gum style --foreground 196 "Please manually mount your partitions to /mnt before continuing."
         echo "Example: mount /dev/sda2 /mnt && mkdir /mnt/boot && mount /dev/sda1 /mnt/boot"
         exit 1
      fi
    fi

    # --- 3. ONBOARDING (Questions) ---
    
    HOSTNAME=$(gum input --placeholder "Hostname (e.g. prism-pc)" --header "Choose a Hostname")
    [ -z "$HOSTNAME" ] && HOSTNAME="prism-pc"

    USERNAME=$(gum input --placeholder "Username (e.g. oliviero)" --header "Create your User")
    [ -z "$USERNAME" ] && exit 1
    
    FULLNAME=$(gum input --placeholder "Full Name" --header "Enter Full Name")
    [ -z "$FULLNAME" ] && FULLNAME="Prism User"

    PASSWORD=$(gum input --password --placeholder "Password" --header "Set User Password")
    [ -z "$PASSWORD" ] && exit 1

    gum style --foreground 212 "Select your Persona Profile:"
    PROFILE=$(gum choose "dev" "gamer" "creator" "pentester" "custom")

    gum style --foreground 212 "Select Primary GPU:"
    GPU=$(gum choose "nvidia" "amd" "intel" "vm" "none")

    # --- 4. CLONE & GENERATE ---
    
    echo ""
    gum spin --title "Fetching latest Prism release..." -- sleep 2
    
    # Get latest tag
    LATEST_TAG=$(curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name")
    [ -z "$LATEST_TAG" ] && LATEST_TAG="main"

    TARGET_DIR="/mnt/etc/nixos"
    mkdir -p "$TARGET_DIR"

    gum spin --title "Generating hardware-configuration.nix..." -- \
      nixos-generate-config --root /mnt --show-hardware-config > "$TARGET_DIR/hardware-configuration.nix"

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
      nixosConfigurations."$HOSTNAME" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          prism.nixosModules.default
          silentSDDM.nixosModules.default

          ({ pkgs, ... }: {
            networking.hostName = "$HOSTNAME";
            system.stateVersion = "24.05";

            prism.hardware.gpu = "$GPU";
            # Auto-detect boot mode: /sys/firmware/efi exists -> uefi, else legacy
            prism.hardware.boot.mode = "uefi"; # Installer defaults to UEFI layout above

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

    # --- 5. INSTALLATION ---
    
    gum style --foreground 212 --border double --padding "1 2" "Ready to Install!"
    echo "Target: $HOSTNAME ($PROFILE) - Tag: $LATEST_TAG"
    
    if gum confirm "Start Installation?"; then
        # --no-root-passwd because we set the user password in the config
        nixos-install --flake "$TARGET_DIR#$HOSTNAME" --no-root-passwd
        
        if gum confirm "Reboot now?"; then
            reboot
        fi
    else
        echo "Installation aborted."
        exit 0
    fi
''
