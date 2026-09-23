# Action Fandango

Action Fandango is a planned UE4SS Lua mod for *The Blood of Dawnwalker*.

The gameplay behavior and controls are being defined. No installable runtime or
release has been produced yet.

The source module name is `ActionFandango`; the intended GitHub repository name is
`BDWActionFandango`.

## Development layout

- `Scripts/`: runtime Lua once the behavior is specified.
- `templates/`: optional UE4SS Templating Engine integration if needed.
- `tests/`: focused offline regressions.
- `tools/`: build and package scripts, excluded from installable archives.
- `docs/`: public usage and integration guidance.

Personal configuration, logs, builds, and installation backups stay outside Git.
