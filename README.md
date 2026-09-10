# RaidSarcasm

RaidSarcasm sends a random sarcastic emote about your current target. It is a small, manually operated addon for the original World of Warcraft: Mists of Pandaria 5.4.8 client (Interface 50400).

Current version: **0.2.0**. See [CHANGELOG.md](CHANGELOG.md) for release history.

## Features

- Ten categories with ten messages each, covering common raid mishaps from low damage to enthusiastic floor inspection.
- One movable menu with readable Blizzard buttons and optional ElvUI styling.
- Position, visibility, expansion, and cooldown saved separately for each character.
- A shared 3-second cooldown for menu buttons and slash commands, configurable from 0 to 60 seconds.
- No consecutive repetition within a category when a different message is available.
- Checks for missing targets, invalid categories, and messages over 255 bytes.
- Screen clamping and a recovery command for the menu.

The addon uses your already selected target; it does not select targets or assess player performance. Messages use the `EMOTE` chat type, not the `RAID` channel, so they are not raid-wide announcements. No message is sent automatically.

## Usage

Enable RaidSarcasm in the character selection addon list and log in. The menu starts visible and collapsed. Click its title to expand it, drag the title with the left mouse button to move it, then select a target and click a category.

| Command | Action |
| --- | --- |
| `/losttank` | Send a Lost Tank emote |
| `/badplay` | Send a Low DPS emote |
| `/nothreat` | Send a No Threat emote |
| `/rsfire` | Send a Standing in Fire emote |
| `/rsinterrupt` | Send a Missed Interrupt emote |
| `/rspull` | Send an Early Pull emote |
| `/rsdead` | Send a Floor Inspector emote |
| `/rstourist` | Send a Raid Tourist emote |
| `/rsmechanic` | Send a Missed Mechanic emote |
| `/rsafk` | Send an AFK Moment emote |
| `/rsmenu` | Toggle menu visibility |
| `/rsmenu show` | Show the menu |
| `/rsmenu hide` | Hide the menu |
| `/rsmenu reset` | Center, collapse, and show the menu; keep the cooldown setting |
| `/rsmenu cooldown 5` | Set a shared 5-second cooldown |
| `/rsmenu cooldown 0` | Disable the cooldown |
| `/rsmenu help` | Show command help |

The first emote after login can be sent immediately. Repetition history and the current cooldown timer reset at login or `/reload`; the configured cooldown duration persists. A category with only one distinct message necessarily repeats it.

## Compatibility

- Intended for the original MoP 5.4.8 client, not Retail or MoP Classic.
- ElvUI is optional. Its integration was checked against the locally installed MoP ElvUI 2.76 source.
- UI initialization waits for `PLAYER_LOGIN`. An ElvUI skinning error is reported without blocking commands or menu initialization; styling may be partially applied.
- Live rendering and server chat behavior still need verification in the target game client.

## Development

The files share WoW's private addon namespace through `local addonName, ns = ...`:

- `Core.lua`: settings validation, message selection, cooldown, login initialization, and slash commands.
- `Emotes.lua`: message text and the ordered `ns.categories` registry.
- `UI.lua`: the single menu, generated category buttons, positioning, and optional styling.

To add a category, append an entry to `ns.categories` in `Emotes.lua`:

```lua
{ id = "example", label = "Example", command = "/rsexample",
  messages = {
      "offers %t a complimentary practice run.",
      "checks whether %t has discovered the mechanic yet."
  }
},
```

Use a unique nonempty ID and slash command, a short label, and a dense list of nonempty strings. `%t` is replaced with the target's name. Both the button and command are generated automatically. Keep the category count modest: the menu grows vertically and does not scroll.

## Verification

From the addon directory, run `lua tests/addon.lua` with Lua 5.1 or newer. The harness loads files in TOC order with a shared namespace and checks login initialization, command and button routing, cooldown, repetition, invalid inputs, saved state, and working/broken/absent ElvUI.

For Fengari, whose `io.open` is unavailable, provide the TOC text in the environment first (PowerShell):

```powershell
$env:RAIDSARCASM_TEST_TOC = Get-Content -Raw RaidSarcasm.toc
fengari tests/addon.lua
```

These are simulated API tests, not a live WoW client test. Before releasing:

1. Enable Lua error reporting with `/console scriptErrors 1`, then `/reload`.
2. Verify readable buttons, expansion, dragging, and screen edges with and without ElvUI.
3. Check each category with a target and without a target; confirm the cooldown and different consecutive messages.
4. Move and hide the menu, then `/reload`; verify saved state and `/rsmenu reset` recovery.
5. Check UI scale/resolution changes and menu use during combat.

## License

RaidSarcasm is available under the [MIT License](LICENSE).
