#!/usr/bin/env bash

set -euo pipefail

VIVALDI_DIR="${VIVALDI_DIR:-$HOME/Library/Application Support/Vivaldi}"

usage() {
  cat <<'EOF'
Usage:
  ./vivaldi/inspect-keybinds.sh --list-profiles
  ./vivaldi/inspect-keybinds.sh --profile "Default" --list
  ./vivaldi/inspect-keybinds.sh --profile "Default" --show COMMAND_SHOW_NOTES_PANEL
  ./vivaldi/inspect-keybinds.sh --profile "Default" --find-shortcut shift+meta+c

Options:
  --profile <name>         Vivaldi profile directory (required unless --list-profiles)
  --list-profiles          List available profile directories and display names
  --list                   List action -> shortcuts
  --show <action_key>      Show one action object
  --find-shortcut <value>  Find actions that include a shortcut value
  -h, --help               Show this help

Environment:
  VIVALDI_DIR              Override Vivaldi data root (default: ~/Library/Application Support/Vivaldi)
EOF
}

list_profiles() {
  python3 - "$VIVALDI_DIR" <<'PY'
import json
import pathlib
import sys

base = pathlib.Path(sys.argv[1]).expanduser()
local_state = base / "Local State"
info_cache = {}

if local_state.exists():
    try:
        data = json.loads(local_state.read_text())
        info_cache = data.get("profile", {}).get("info_cache", {})
    except Exception:
        info_cache = {}

profiles = []
if base.exists():
    for child in base.iterdir():
        if not child.is_dir():
            continue
        name = child.name
        if name == "Default" or name.startswith("Profile "):
            if (child / "Preferences").exists():
                friendly = info_cache.get(name, {}).get("name", name)
                profiles.append((name, friendly))

profiles.sort(key=lambda x: (x[0] != "Default", x[0]))
for profile_dir, friendly in profiles:
    print(f"{profile_dir}\t{friendly}")
PY
}

PROFILE=""
MODE=""
ACTION_KEY=""
SHORTCUT_VALUE=""

while (($# > 0)); do
  case "$1" in
    --profile)
      if (($# < 2)); then
        echo "Error: --profile requires a value" >&2
        exit 1
      fi
      PROFILE="$2"
      shift 2
      ;;
    --list-profiles)
      MODE="list-profiles"
      shift
      ;;
    --list)
      MODE="list"
      shift
      ;;
    --show)
      if (($# < 2)); then
        echo "Error: --show requires an action key" >&2
        exit 1
      fi
      MODE="show"
      ACTION_KEY="$2"
      shift 2
      ;;
    --find-shortcut)
      if (($# < 2)); then
        echo "Error: --find-shortcut requires a value" >&2
        exit 1
      fi
      MODE="find"
      SHORTCUT_VALUE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Error: choose one mode: --list-profiles, --list, --show, --find-shortcut" >&2
  usage >&2
  exit 1
fi

if [[ "$MODE" == "list-profiles" ]]; then
  list_profiles
  exit 0
fi

if [[ -z "$PROFILE" ]]; then
  echo "Error: --profile is required for this mode" >&2
  usage >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 1
fi

PREFERENCES_FILE="$VIVALDI_DIR/$PROFILE/Preferences"
if [[ ! -f "$PREFERENCES_FILE" ]]; then
  echo "Error: Preferences file not found: $PREFERENCES_FILE" >&2
  exit 1
fi

case "$MODE" in
  list)
    jq -r '.vivaldi.actions[0] | to_entries[] | select(.value.shortcuts? != null) | "\(.key)\t\(.value.shortcuts | join(", "))"' "$PREFERENCES_FILE"
    ;;
  show)
    jq --arg key "$ACTION_KEY" '.vivaldi.actions[0][$key]' "$PREFERENCES_FILE"
    ;;
  find)
    jq -r --arg shortcut "$SHORTCUT_VALUE" '.vivaldi.actions[0] | to_entries[] | select((.value.shortcuts // []) | index($shortcut)) | .key' "$PREFERENCES_FILE"
    ;;
esac
