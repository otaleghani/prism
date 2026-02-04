{ pkgs, writeShellScriptBin }:

let
  deps = [
    pkgs.gum
    pkgs.gnused
    pkgs.gnugrep
    pkgs.coreutils
  ];
in
writeShellScriptBin "prism-users" ''
    export PATH=${pkgs.lib.makeBinPath deps}:$PATH

    # Locate Config
    if [ -d "/etc/prism" ]; then
        CONFIG_DIR="/etc/prism"
    elif [ -d "$HOME/.config/prism" ]; then
        CONFIG_DIR="$HOME/.config/prism"
    else
        # Fallback for dev/testing
        CONFIG_DIR="."
    fi
    
    USER_FILE="$CONFIG_DIR/users.nix"

    if [ ! -f "$USER_FILE" ]; then
        gum style --foreground 196 "Error: $USER_FILE not found."
        exit 1
    fi

    ACTION=$(gum choose "Add User" "Remove User" "List Users")

    case "$ACTION" in
      "List Users")
        gum style --border normal --padding "1 2" "Current Prism Users:"
        grep "prism.users." "$USER_FILE" | cut -d'.' -f3 | cut -d' ' -f1
        ;;

      "Add User")
        USERNAME=$(gum input --placeholder "username" --header "New Username (lowercase)")
        [ -z "$USERNAME" ] && exit 1
        
        # Check if exists
        if grep -q "prism.users.$USERNAME =" "$USER_FILE"; then
            gum style --foreground 196 "User $USERNAME already exists!"
            exit 1
        fi

        FULLNAME=$(gum input --placeholder "Full Name" --header "Display Name")
        [ -z "$FULLNAME" ] && FULLNAME="$USERNAME"

        PASSWORD=$(gum input --password --placeholder "Initial Password" --header "Password")
        [ -z "$PASSWORD" ] && exit 1

        PROFILE=$(gum choose "dev" "gamer" "creator" "pentester" "custom")
        
        gum style --foreground 212 "Adding $USERNAME ($PROFILE)..."

        # Generate the block
        BLOCK="  # --- USER: $USERNAME ---\n  prism.users.$USERNAME = {\n    description = \"$FULLNAME\";\n    profileType = \"$PROFILE\";\n    isNormalUser = true;\n    initialPassword = \"$PASSWORD\";\n    extraGroups = [ \"wheel\" \"networkmanager\" \"video\" \"audio\" ];\n  };\n  # --- END USER: $USERNAME ---"

        # Append before the last closing brace '}'
        # We assume the file ends with '}' on the last line.
        # using sed to insert before the last line
        sed -i "$ i \\
  $BLOCK" "$USER_FILE"
        
        gum style --foreground 212 "User added to config."
        
        if gum confirm "Rebuild system now to apply changes?"; then
            sudo nixos-rebuild switch --flake "$CONFIG_DIR"#prism
        fi
        ;;

      "Remove User")
        # Extract list of users from the file markers
        USERS=$(grep "# --- USER:" "$USER_FILE" | cut -d':' -f2 | tr -d ' ')
        
        if [ -z "$USERS" ]; then
            gum style --foreground 196 "No users found to remove."
            exit 1
        fi
        
        TARGET=$(echo "$USERS" | gum choose --header "Select User to Remove")
        [ -z "$TARGET" ] && exit 0
        
        if gum confirm "Are you sure you want to remove $TARGET?"; then
            # Use sed to delete the block between the markers
            sed -i "/# --- USER: $TARGET ---/,/# --- END USER: $TARGET ---/d" "$USER_FILE"
            
            gum style --foreground 212 "User $TARGET removed from config."
            
            if gum confirm "Rebuild system now to apply changes?"; then
                sudo nixos-rebuild switch --flake "$CONFIG_DIR"
            fi
        fi
        ;;
    esac
''
