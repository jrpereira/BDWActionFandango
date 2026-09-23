# Action Fandango

Action Fandango is a UE4SS Templating Engine (TE) template for *The Blood of
Dawnwalker*. It replaces the native swappable quickslots display with two visible
wheels: four existing Ability slots and four existing Consumable slots. It creates
no skills. The input contract is **one key per slot**, so each action keeps its own
binding regardless of the wheel position.

Two arrangements are available: **Stacked** and **Side by side**. You can choose
which wheel occupies the primary position, set an anchor and spacing, and adjust
the size and opacity of each wheel. Switching arrangements preserves the native
Ability and Consumable widgets and restores their original hierarchy and visual
state when the template is disabled.

The source module name is `ActionFandango`; the intended GitHub repository name is
`BDWActionFandango`.

## Current status

The template passes offline lifecycle and TE registration checks. TE `0.0.18` is
a menu-test host: its native input and visual cutover are still under development,
and its installed menu profile has a fixed template list. Action Fandango is not
registered in that profile or installed as a playable mod yet. In-game layout,
input, and game lifecycle behavior have not been accepted.

When TE supports the native cutover, it must register
`ActionFandango/templates/action_fandango.lua` and generate its menu page. Selecting
Action Fandango in the `player.quickslots` category replaces the QSF template
because the category allows one active template. Select **1 key per slot** for
separate action inputs. The template refuses group-first input rather than
silently using shared slot actions.

The host must invoke `attach`, `render`, and `detach` on the game thread and supply
the live QuickslotsSwitcher through TE's `player.quickslots` service. Native input
ownership and gating remain TE's responsibility. Action Fandango changes only the
widget layout and restores its changes on detach.

Run offline checks from the Gaming workspace:

```sh
lua ActionFandango/tests/registration_test.lua
cd ActionFandango && lua tests/template_test.lua
```

## Development layout

- `templates/`: the TE runtime template and menu settings.
- `tests/`: focused offline regressions.
- `tools/`: build and package scripts if a release workflow is added; tools must
  stay outside installable archives.
- `docs/`: public usage and integration guidance if the interface expands.

Personal configuration, logs, builds, and installation backups stay outside Git.
