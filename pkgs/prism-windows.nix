{
  lib,
  writeShellApplication,
  runCommand,
  xorriso,
  coreutils,
  libvirt,
  virt-manager,
  virt-viewer,
  virtio-win,
  powershell,
}:

let
  setupIso = runCommand "prism-windows-setup.iso" { nativeBuildInputs = [ xorriso ]; } ''
    mkdir contents
    cp ${./windows/cleanup.ps1} contents/cleanup.ps1
    xorriso -as mkisofs -quiet -J -r -V PRISM_SETUP -o "$out" contents
  '';
in
writeShellApplication {
  name = "prism-windows";
  runtimeInputs = [
    coreutils
    libvirt
    virt-manager
    virt-viewer
  ];

  text = ''
    if [[ "''${1:-}" == --help || "''${1:-}" == -h ]]; then
      echo 'Usage: prism-windows /path/to/windows-11-x64.iso'
      echo 'Creates prism-windows: 4 CPUs, 8 GiB RAM, 80 GiB sparse disk.'
      echo 'Complete Windows setup, then run cleanup.ps1 from the PRISM_SETUP CD.'
      echo 'Open Virtual Machine Manager to start it again or adjust its hardware.'
      exit 0
    fi
    if [[ $# != 1 || ! -f "$1" || ! -r "$1" ]]; then
      echo 'Usage: prism-windows /path/to/windows-11-x64.iso (readable ISO required)' >&2
      exit 1
    fi

    vm_names=$(virsh --connect qemu:///system list --all --name)
    if [[ $'\n'"$vm_names"$'\n' == *$'\nprism-windows\n'* ]]; then
      echo 'prism-windows already exists. Open it in Virtual Machine Manager.' >&2
      exit 1
    fi

    # libvirt tries to index all of /nix/store if an ISO is attached from there.
    media_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/prism/windows"
    if [[ "$media_dir" == *,* ]]; then
      echo 'XDG_DATA_HOME must not contain commas (virt-install disk syntax).' >&2
      exit 1
    fi
    install -Dm644 ${virtio-win.src} "$media_dir/virtio-win.iso"
    install -Dm644 ${setupIso} "$media_dir/prism-setup.iso"

    # SATA and e1000e let Windows setup use its built-in storage/network drivers.
    # User networking provides internet without configuring a host bridge.
    exec virt-install \
      --connect qemu:///system \
      --name prism-windows \
      --osinfo win11 \
      --virt-type kvm \
      --arch x86_64 \
      --machine q35 \
      --cpu host-passthrough \
      --vcpus 4,sockets=1,cores=4,threads=1 \
      --memory 8192 \
      --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=yes \
      --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
      --disk size=80,format=qcow2,bus=sata \
      --cdrom "$(realpath -- "$1")" \
      --disk "path=$media_dir/virtio-win.iso,device=cdrom,bus=sata,readonly=on" \
      --disk "path=$media_dir/prism-setup.iso,device=cdrom,bus=sata,readonly=on" \
      --network user,model=e1000e \
      --graphics spice,listen=none \
      --video qxl \
      --sound ich9 \
      --audio id=1,type=spice \
      --input tablet,bus=usb
  '';

  passthru.tests.cleanup =
    runCommand "prism-windows-cleanup-check"
      {
        nativeBuildInputs = [ powershell ];
      }
      ''
        pwsh -NoProfile -File ${./windows/check-cleanup.ps1} ${./windows/cleanup.ps1}
        touch "$out"
      '';

  meta = {
    description = "Create a Windows 11 VM with optional bundled-app cleanup";
    mainProgram = "prism-windows";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}
