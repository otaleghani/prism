#!/usr/bin/env python3
"""Validate every Prism profile/theme with Hyprland, without starting a session.

Usage: python3 scripts/check-hyprland-config.py [path/to/Hyprland]
"""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parents[1]
common = root / "defaults/common/.config/hypr"
profiles = {"custom": common / "mode.lua"}
profiles.update(
    (path.relative_to(root / "defaults").parts[0], path)
    for path in sorted((root / "defaults").glob("*/.config/hypr/mode.lua"))
    if path.parent != common
)
themes = sorted((root / "defaults/themes").glob("*/hypr.lua"))
hyprland = sys.argv[1] if len(sys.argv) > 1 else "Hyprland"

with tempfile.TemporaryDirectory(prefix="prism-hyprland-check-") as directory:
    stage = Path(directory)
    shutil.copytree(common, stage / "config/hypr")
    (stage / "data/prism").mkdir(parents=True)
    (stage / "runtime").mkdir(mode=0o700)
    (stage / "cache").mkdir()
    env = os.environ | {
        "XDG_CONFIG_HOME": str(stage / "config"),
        "XDG_DATA_HOME": str(stage / "data"),
        "XDG_RUNTIME_DIR": str(stage / "runtime"),
        "XDG_CACHE_HOME": str(stage / "cache"),
    }
    for profile, mode in profiles.items():
        shutil.copyfile(mode, stage / "config/hypr/mode.lua")
        for theme in themes:
            current = stage / "data/prism/current"
            if current.is_symlink():
                current.unlink()
            current.symlink_to(theme.parent, target_is_directory=True)
            result = subprocess.run(
                [hyprland, "--verify-config", "-c", str(stage / "config/hypr/hyprland.lua")],
                env=env,
                capture_output=True,
                text=True,
                timeout=30,
            )
            output = result.stdout + result.stderr
            if result.returncode or "\nconfig ok\n" not in output:
                sys.exit(f"FAIL {profile}/{theme.parent.name}:\n{output}")
        print(f"PASS {profile}: {len(themes)} themes")

print(f"Validated {len(profiles) * len(themes)} profile/theme combinations.")
