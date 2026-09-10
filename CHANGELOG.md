# Changelog

All notable changes to RaidSarcasm are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.2.0 - 2026-09-10

### Added

- Ten categories with ten emotes each, for a total of 100 messages.
- Categories for standing in fire, missed interrupts, early pulls, floor inspection, raid tourists, missed mechanics, and AFK moments.
- Automatically generated menu buttons and slash commands from a shared category registry.
- Per-character saved menu position, visibility, expanded state, and cooldown duration.
- Configurable shared cooldown with `/rsmenu cooldown 0-60`.
- `/rsmenu show`, `/rsmenu hide`, `/rsmenu reset`, and `/rsmenu help` commands.
- Screen clamping, position recovery, and protection against consecutive message repetition.
- Input validation and a simulated WoW API test suite.
- MIT license.

### Changed

- Reworked the addon around WoW's private addon namespace.
- Consolidated the interface into one menu and made category creation data-driven.
- Made ElvUI an optional dependency and isolated styling failures from core behavior.
- Expanded the user and development documentation.

### Fixed

- Fixed message tables and helper functions being inaccessible across Lua files.
- Fixed `UI.lua` failing during load because it referenced private functions from `Core.lua`.
- Fixed duplicate creation of the named menu frame.
- Fixed unreadable unstyled buttons by using the standard Blizzard button template.
- Fixed misleading successful-load messages being printed before initialization completed.

## 0.1.0 - 2026-08-21

### Added

- Initial Lost Tank, Low DPS, and No Threat emotes.
- Movable menu, slash commands, and basic ElvUI styling.
