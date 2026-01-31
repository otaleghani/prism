# Boot

prism.hardware.boot option

For Modern PCs: `prism.hardware.boot.mode = "uefi";`
(and optionally set efiMount if it's not /boot).

For VMs/Old PCs: `prism.hardware.boot.mode = "legacy";`
(and optionally set device if it's not /dev/sda).
