# Action Fandango

Action Fandango provides two UE4SS Templating Engine (TE) quickslots templates for
*The Blood of Dawnwalker*. Both use the four existing Ability and four existing
Consumable slots. Neither creates skills.

**Dual Wheels** is the first playable target. It replaces the swappable quickslots
display with two visible wheels and requires **one key per slot**. Each action keeps
its own binding regardless of wheel position. Stacked and side by side layouts are
available. You can choose the primary wheel, position and spacing, and adjust each
wheel's size and opacity. Disabling the template restores the native widget layout.

**Swapping Fixed** keeps the native swappable display and uses **Activate group
first** input. Its current configuration requires Abilities as the default group,
with an unbound Default group action, and a Tap binding for Consumables. TE's input
host implements the return to Abilities when the Consumables key is tapped again.
The template validates this configuration and selects the Ability wheel on attach;
it does not own native input behavior.

The source module name is `ActionFandango`; the intended GitHub repository name is
`BDWActionFandango`.

## Current status

Both templates pass offline lifecycle and TE registration checks. TE `0.0.18` is
a menu-test host: its native input and visual cutover are still under development,
and its installed menu profile has a fixed template list. Action Fandango is not
registered in that profile or installed as a playable mod yet. In-game layout,
input, and game lifecycle behavior have not been accepted.

When TE supports the native cutover, it must register
`ActionFandango/Scripts/action_fandango.lua` and generate both menu choices.
Selecting either choice in the `player.quickslots` category replaces the previous
quickslots template because the category allows one active template. Dual Wheels
refuses group-first input; Swapping Fixed refuses direct slot input and unsupported
group configurations.

The host must invoke `attach`, `render`, and `detach` on the game thread and supply
the live QuickslotsSwitcher through TE's `player.quickslots` service. Native input
ownership and gating remain TE's responsibility. Action Fandango changes only the
widget layout and restores its changes on detach.

Run offline checks from the Gaming workspace:

```sh
lua5.4 ActionFandango/tests/registration_test.lua
lua5.4 ActionFandango/tests/template_test.lua
```

## Development layout

- `Scripts/action_fandango.lua`: the single TE registration entry point.
- `Scripts/templates/`: the two runtime templates and their menu settings.
- `tests/`: focused offline regressions.
- `tools/`: build and package scripts if a release workflow is added; tools must
  stay outside installable archives.
- `docs/`: public usage and integration guidance if the interface expands.

Personal configuration, logs, builds, and installation backups stay outside Git.
