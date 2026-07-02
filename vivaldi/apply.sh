#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VIVALDI_DIR="${VIVALDI_DIR:-$HOME/Library/Application Support/Vivaldi}"
MANAGED_FILE="$SCRIPT_DIR/managed-settings.json"

usage() {
  cat <<'EOF'
Usage:
  ./vivaldi/apply.sh --profile "Default"
  ./vivaldi/apply.sh --list-profiles

Options:
  --profile <name>   Vivaldi profile directory (required unless --list-profiles)
  --list-profiles    List available profile directories and display names
  -h, --help         Show this help

Environment:
  VIVALDI_DIR        Override Vivaldi data root (default: ~/Library/Application Support/Vivaldi)
  VIVALDI_ALLOW_RUNNING=1  Skip running-process check (use carefully)
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
LIST_ONLY=0

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
      LIST_ONLY=1
      shift
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

if ((LIST_ONLY == 1)); then
  list_profiles
  exit 0
fi

if [[ -z "$PROFILE" ]]; then
  echo "Error: --profile is required" >&2
  usage >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 1
fi

if [[ ! -f "$MANAGED_FILE" ]]; then
  echo "Error: managed settings file not found: $MANAGED_FILE" >&2
  exit 1
fi

if [[ "${VIVALDI_ALLOW_RUNNING:-0}" != "1" ]] && pgrep -x "Vivaldi" >/dev/null 2>&1; then
  echo "Error: Vivaldi is running. Close it before applying settings." >&2
  exit 1
fi

PREFERENCES_FILE="$VIVALDI_DIR/$PROFILE/Preferences"
if [[ ! -f "$PREFERENCES_FILE" ]]; then
  echo "Error: Preferences file not found: $PREFERENCES_FILE" >&2
  exit 1
fi

BACKUP_DIR="$SCRIPT_DIR/backups/$PROFILE"
mkdir -p "$BACKUP_DIR"
STAMP="$(date +"%Y%m%d-%H%M%S")"
BACKUP_FILE="$BACKUP_DIR/Preferences.$STAMP.bak"
cp "$PREFERENCES_FILE" "$BACKUP_FILE"

TMP_FILE="$(mktemp "${TMPDIR:-/tmp}/vivaldi-apply.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT

jq --slurpfile managed "$MANAGED_FILE" '
  def deepmerge($base; $patch):
    if ($base | type) == "object" and ($patch | type) == "object" then
      reduce ((($base | keys_unsorted) + ($patch | keys_unsorted)) | unique[]) as $k
        ({}; .[$k] = deepmerge($base[$k]; $patch[$k]))
    elif ($base | type) == "array" and ($patch | type) == "array" then
      reduce range(0; ([($base | length), ($patch | length)] | max)) as $i
        ([];
          . + [
            if $i < ($patch | length) then
              if $i < ($base | length) then
                deepmerge($base[$i]; $patch[$i])
              else
                $patch[$i]
              end
            else
              $base[$i]
            end
          ]
        )
    elif $patch == null then
      $base
    else
      $patch
    end;
  deepmerge(.; $managed[0])
' "$PREFERENCES_FILE" > "$TMP_FILE"

jq empty "$TMP_FILE" >/dev/null
mv "$TMP_FILE" "$PREFERENCES_FILE"
trap - EXIT

echo "Applied managed settings to profile: $PROFILE"
echo "Backup created: $BACKUP_FILE"
echo "Reminder: paste ./vivaldi/vimium-mappings.txt into Vimium Custom key mappings if needed."
