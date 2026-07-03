# Vivaldi Note

There is no Sync features for Vivaldi yet, so you need to save your notes manually.

## Scripted sync

These scripts sync only targeted settings from `vivaldi/managed-settings.json`.

Close Vivaldi before applying settings.

```bash
./vivaldi/apply.sh --list-profiles
./vivaldi/inspect-keybinds.sh --list-profiles

# On another machine, validate then apply tracked settings
./vivaldi/apply.sh --check --profile "Default"
./vivaldi/apply.sh --profile "Default"
```

Vimium key mappings are kept in `vivaldi/vimium-mappings.txt` and should be pasted in Vimium options manually.

## Update keybind workflow

When you change a shortcut in Vivaldi and want to sync it to other machines:

1. Change the shortcut in Vivaldi UI.
2. Quit Vivaldi fully.
3. Inspect the action/value from `Preferences`.
4. Update the matching action in `vivaldi/managed-settings.json`.
5. Run `./vivaldi/apply.sh --check --profile "Default"`.
6. Run `./vivaldi/apply.sh --profile "Default"` (or your target profile).
7. Reopen Vivaldi and verify keyboard shortcuts.

Useful commands:

```bash
# List action -> shortcuts for a profile
./vivaldi/inspect-keybinds.sh --profile "Default" --list

# Show one action value
./vivaldi/inspect-keybinds.sh --profile "Default" --show COMMAND_SHOW_NOTES_PANEL

# Find action key by shortcut value
./vivaldi/inspect-keybinds.sh --profile "Default" --find-shortcut shift+meta+c
```

Keep managed keys minimal: only shortcuts you intentionally sync.

## Safety checks

`./vivaldi/apply.sh --check --profile "Default"` validates both files before any write:

- `managed-settings.json` must contain `vivaldi.actions[0]` as an object of actions with `shortcuts` arrays.
- `Preferences` must contain existing `vivaldi.actions[0]` baseline (script does not create it).

If `--check` fails with missing `vivaldi.actions`, open Vivaldi Keyboard settings once to create the baseline, quit Vivaldi, then run check/apply again.

## Keyboard Shortcuts

Page > Copy Selected Text to Note : Command + Option + C
Tab > Move Active Tab Backward    : Control + Shift + Page Up
Tab > Move Active Tab Forward     : Control + Shift + Page Down
Tab > Remove from Tab Stack       : Control + Shift + T
View > Toggle Floating Panel      : Command + Shift + \
View > Notes Panel                : Command + Shift + C
View > Open Next Panel            : Command + Shift + J
View > Open Previous Panel        : Command + Shift + K
View > Address Bar                : Command + Shift + L
View > Panel                      : Command + Shift + P

**Note**
For Bitwarden conflict password autofill
Change Bitwarden's shortcut to Command + Control + L

Download Panel and Mail Panel are not managed by the script because removing them from `shortcuts` can break Vivaldi's keyboard settings UI in some versions.

## Vimium

Custom key mappings

```vim
map X removeTab
unmap x
map ' Marks.activateGotoMode swap
map m Marks.activateCreateMode swap
```
