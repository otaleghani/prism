{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.parted
    pkgs.util-linux
    pkgs.dosfstools
    pkgs.e2fsprogs
    pkgs.gawk
  ];
in
writeShellScriptBin "prism-installer-partition" ''
  export PATH=${pkgs.lib.makeBinPath deps}:$PATH
  STATE_FILE="$1"

  # DETECT BOOT MODE 
  if [ -d /sys/firmware/efi/efivars ]; then
      BOOT_MODE="uefi"
      echo "System is booted in UEFI mode."
  else
      BOOT_MODE="legacy"
      echo "System is booted in Legacy BIOS mode."
  fi
  sleep 1

  # Export to state file
  echo "BOOT_MODE=$BOOT_MODE" >> "$STATE_FILE"

  # PARTITIONING LOGIC 
  if mountpoint -q /mnt; then
    echo "Filesystem already mounted at /mnt. Skipping partitioning."
  else
    CHOICE=$(gum choose "Automatic Partitioning (Wipe Drive)" "Manual Partitioning (cfdisk)" "I have already mounted /mnt")
    
    if [ "$CHOICE" == "Automatic Partitioning (Wipe Drive)" ]; then
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
       
       # Save Target Disk to state (needed for Legacy GRUB install)
       echo "TARGET_DISK=$TARGET_DISK" >> "$STATE_FILE"
       
       echo "Partitioning $TARGET_DISK for $BOOT_MODE..."
       wipefs -a "$TARGET_DISK"
       
       if [ "$BOOT_MODE" == "uefi" ]; then
           # UEFI (GPT + ESP)
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
           # Legacy (GPT + BIOS Boot)
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
       
    elif [ "$CHOICE" == "Manual Partitioning (cfdisk)" ]; then
       echo "Scanning disks..."
       DISKS=$(lsblk -d -n -o NAME,SIZE,MODEL -e 7,11)
       SELECTED_LINE=$(echo "$DISKS" | gum choose --header "Select Drive to Partition")
       DISK_NAME=$(echo "$SELECTED_LINE" | awk '{print $1}')
       
       cfdisk "/dev/$DISK_NAME"
       
       echo "Please format and mount your partitions via shell now."
       if gum confirm "Open Shell?"; then
           echo "Type 'exit' to return to installer."
           bash
       else
           exit 1
       fi
       
       if ! mountpoint -q /mnt; then
           gum style --foreground 196 "Error: /mnt is not mounted."
           exit 1
       fi
    fi
  fi
''
