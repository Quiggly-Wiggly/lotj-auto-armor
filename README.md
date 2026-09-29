# LotJ Auto Armor

Queue armor work and enhancements in Legends of the Jedi. Maintained by
Quiggly-Wiggly from the local AutoArmorEnhanced package.

## Install

Download **LotJ Auto Armor.mpackage** from [Releases](https://github.com/Quiggly-Wiggly/lotj-auto-armor/releases/latest).
Uninstall the older AutoArmor or AutoArmorEnhanced package, then install this
package in Mudlet's Package Manager. Its package ID remains `AutoArmorEnhanced`
for upgrade compatibility. Requires Mudlet 4.20+.

Type `autoarmor` for the compact colored menu. No recipes, item names, character
information, or queues are bundled. Loading never starts work. Use your own item
keywords and enhancement names learned in game:

```text
autoarmor add <armor keyword>
autoarmor enhance <armor keyword> <enhancement>
autoarmor start
```

The angle-bracket placeholders must be replaced. Setup links fill the input line;
review and press Enter. Enhancements run before armor construction.

| Command | Action |
| --- | --- |
| `autoarmor stop` | Pause work |
| `autoarmor resume` | Resume the current step |
| `autoarmor next` | Skip the current entry |
| `autoarmor list` | View both queues |
| `autoarmor clear` | Stop and clear both queues |
| `autoarmor status` | Progress and counts |
| `autoarmor help` | Commands |

Each stitch examines the current item before `makearmor`. Completed enhancements
are examined before advancing. Failed enhancements retry; invalid enhancement
targets are skipped during subsequent armor work. Watch the game output and stop
when needed. Queues are session-only, and reconnecting requires explicit resume.
BOT/AFK recovery only runs while active with queued work; disable the
`autoarmor.botstart` trigger if another package manages that behavior. Stop cannot
recall commands already sent.

## Development

```sh
python3 scripts/build.py
python3 -m unittest discover -s tests -v
```

Python standard library plus LuaJIT/Lua 5.1. Sources, XML trigger definitions,
synthetic tests, and one installable package are included. No profile is needed
to build. Tests cover queue flow, literal colored output, command prefill, and
no automation on install/disconnect. Native visual and live crafting checks
remain manual.
