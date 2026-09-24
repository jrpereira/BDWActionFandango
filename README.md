# Action Fangdango

Arrange your ability and consumable wheels to suit your playstyle. Show both at once or switch between them, with adjustable position, size, and opacity. A little choreography for your combat HUD.

## What you can change

| Setting | What it does |
|---|---|
| **Swap** | Shows one wheel at a time, with both using the same position, size, and opacity. This is the default. |
| **Distant** | Shows both wheels, with separate appearance settings for each. |
| **X / Y** | Moves the wheel horizontally or vertically from its usual position. |
| **Size** | Changes wheel size. 100% is the normal size. |
| **Opacity** | Changes visibility, from invisible at 0% to fully visible at 100%. |

In Distant mode, **Wheel 1** contains abilities and **Wheel 2** contains
consumables. Each style remembers its settings when you switch to the other.
The mod rearranges the existing wheels; it does not add skills or change their keys.

## Requirements

- **UE4SS for your Dawnwalker game version.** See the loader links in the
  [Dawnwalker Mod Menu requirements](https://www.nexusmods.com/thebloodofdawnwalker/mods/271).
- [Dawnwalker Mod Menu](https://www.nexusmods.com/thebloodofdawnwalker/mods/271).
- [ModCoreSettings](https://www.nexusmods.com/thebloodofdawnwalker/mods/590).
- [ModCoreTemplates](https://www.nexusmods.com/thebloodofdawnwalker/mods/641),
  with support for Action Fangdango's **Wheels** option.

ModCoreControls is optional for changing input layouts; it is not required just
to choose a wheel style. If you use it, follow its own dependency requirements.

## Installation

1. Close the game completely. Extract the mod download so its `ActionFangdango`
   folder sits directly inside the game's `ue4ss/Mods` folder.
2. Download any missing dependencies above and install them with the game closed.
   Use each download's instructions: some archives already include the full
   game-folder path, and UE4SS itself does not install inside `Mods`.
3. Ensure the mods are enabled in your UE4SS setup or mod manager, then restart
   the game. Avoid an extra nested `ActionFangdango/ActionFangdango` folder.

## First use

Open **Mod Settings** and find **Action Fangdango**. Select **Wheels**, choose
**Swap** or **Distant**, then adjust the visible settings and choose **Apply**.
Start with Swap at 100% size and opacity, then change one setting at a time.

Updating from **Wheels++**? Select **Wheels** again; the older option has been
removed. This Wheels update is awaiting in-game verification.

## If something looks wrong

- **No Action Fangdango page or Wheels option:** check that the required mods are
  enabled and that your ModCoreTemplates version supports Wheels, then restart.
- **A wheel disappeared:** restore its opacity and size to 100%, and X/Y to 0.
  In Distant mode, give Wheel 2 a different X value so the wheels do not overlap.
- **A key behaves differently than expected:** Action Fangdango changes appearance.
  Check the game's controls or your input mod's settings.

## Updating or removing

Close the game before replacing or removing the mod folder. Preserve your saved
settings and any dependency settings when updating. To remove Action Fangdango,
disable or remove its folder and restart; keep dependencies used by other mods.

See the [changelog](CHANGELOG.md) for changes.
