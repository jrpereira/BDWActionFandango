# Action Fandango

Action Fandango provides one UE4SS Templating Engine (TE) quickslots template for
*The Blood of Dawnwalker*. It uses the four existing Ability and four existing
Consumable slots and creates no new skills.

**Wheels++** displays both native quickslot wheels. Choose **Individual** for one
key per slot, or **Advanced** for direct slot keys plus separate group keys. In
Advanced mode, select a group's key before using its direct slot keys. Both wheels
remain visible, and bindings stay with their Ability or Consumable slots.

**Advanced Options** switches between three views. **More...** shows Default Wheel
and Layout (Overlap, Stacked, or Side by side). **Primary** shows X, Y, Size, and
Opacity for the default wheel; **Secondary** shows independent X, Y, Size, and
Opacity for the other wheel. X and Y are offsets from each wheel's original
position after the selected layout places it. Disabling the template restores the
original native wheel hierarchy and visual properties.

The source module name is `ActionFandango`; the intended GitHub repository name is
`BDWActionFandango`.

## Current status

Wheels++ passes offline template lifecycle and TE registration checks. TE owns
native input and selection; Action Fandango owns the wheel layout. In-game layout,
input, and lifecycle behavior still need live acceptance.

The new menu registers only Wheels++. An existing selection of the removed
Swapping Fixed choice becomes None when TE refreshes the menu; select Wheels++
after updating. Existing Arrangement values retain their meanings: 0 is Stacked,
1 is Side by side, and 2 is Overlap.

Run offline checks from the Gaming workspace:

```sh
lua5.4 ActionFandango/tests/registration_test.lua
lua5.4 ActionFandango/tests/template_test.lua
```

## Development layout

- `Scripts/templates/main.lua`: the single TE registration entry point.
- `Scripts/templates/`: the active Wheels++ template and its menu settings.
- `tests/`: focused offline regressions.
- `tools/`: build and package scripts if a release workflow is added; tools must
  stay outside installable archives.
- `docs/`: public usage and integration guidance if the interface expands.

Personal configuration, logs, builds, and installation backups stay outside Git.
