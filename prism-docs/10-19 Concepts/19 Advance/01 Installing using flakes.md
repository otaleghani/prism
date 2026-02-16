# Installing using flakes

This guide is for the "Nix-savvy" users who already have a NixOS system running and want to migrate to the Prism ecosystem without using the ISO installer. By following this method, you adopt the **certified release** model, allowing Prism to manage your core system versions.

## Manual Flake installation

If you already have a `hardware-configuration.nix` and a functioning NixOS base, you can "Prism-ify" your system by creating a new `flake.nix` in `/etc/prism`.

### `flake.nix`

First off, get the latest tag by visiting the GitHub page or running this script:
```bash
curl -sL https://api.github.com/repos/otaleghani/prism/releases/latest | jq -r ".tag_name"
```

Create a `flake.nix` with the following structure. Note that we omit a top-level `nixpkgs` input to ensure we follow the Prism Maintainer's certified package set.

```
{
  description = "Prism Manual Transition Flake";

  inputs = {
    # We pull the entire ecosystem from the Prism flake
    # Remember to change $TAG_NAME with the latest prism version
    prism.url = "github:otaleghani/prism/$TAG_NAME";
  };

  outputs = { self, prism, ... }@inputs: {
    nixosConfigurations.prism = prism.inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Import your existing hardware detection
        ./hardware-configuration.nix

        # Import your Prism user definitions
        ./users.nix

        # Import the core Prism logic
        prism.nixosModules.default

        # Hardware & System Toggles
        ( { prism, ... }: {
          prism.hardware.boot.mode = "uefi"; # or "bios"
          prism.hardware.gpu = "nvidia";     # "nvidia", "amd", or "intel"
        })
      ];
    };
  };
}
```

Here's an example of the `./users.nix` file.

```nix
{ ... }:
{
  # --- USER: developer ---
  prism.users.developer = {
    profileType = "dev";
    description = "developer";
    isNormalUser = true;
    icon = ./icon.jpeg; # You can add an icon here
    initialPassword = "somepass";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = [ ];
  };
  # --- END USER: oliviero ---
  # --- USER: gamer ---
  prism.users.gamer = {
    description = "gamer";
    profileType = "gamer";
    isNormalUser = true;
    initialPassword = "somepass";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };
  # --- END USER: gamer ---
}

```

### Preparation checklist

Before you run the rebuild, ensure the following files are present in the same directory as your new `flake.nix`:

- **`hardware-configuration.nix`**: Copy this from your current `/etc/nixos/hardware-configuration.nix`.
- **`users.nix`**: Define your Prism users here using the `prism.users` option we documented in the **Users** section.

### Applying the Transition

Once your files are in place, initialize the flake and switch your system profile.

```bash
# Move to your config directory
cd /etc/prism

# Apply the configuration
sudo nixos-rebuild switch --flake .#prism
```

## Why this approach?

- **Safety:** You keep your existing hardware configuration, ensuring your disks and drivers remain correctly mapped.
- **Consistency:** By using `prism.inputs.nixpkgs.lib.nixosSystem`, you guarantee that your manual install is identical to an ISO-based install.
- **Control:** You can slowly move your old `configuration.nix` settings into the `overrides/` folder as you get used to the Prism workflow.