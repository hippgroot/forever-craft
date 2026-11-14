# Changelog

All notable changes to Forever Craft. Newest version first.
Each version is also tagged in git (`v1.1.0`) and has a matching GitHub Release.

<!--
Template for a new version (copy above the latest entry):

## [1.2.0] - YYYY-MM-DD
### Added
- 
### Updated
- 
### Removed
- 
### Config
- 
-->

## [1.2.2] - 2026-11-14
### Updated
- C2ME 0.4.2-alpha.0.115 -> 0.4.2-alpha.0.119
- Collective 8.73 -> 8.86
- Easy Magic 26.3.0 -> 26.3.1
- Entity Culling 1.11.3 -> 1.12.1
- Fabric API 0.165.0 -> 0.166.2
- JamLib 2.3.1 -> 2.3.2
- Just Enough Items (JEI) 31.17.0.108 -> 31.17.0.113
- Mezz Config 0.6.10 -> 0.7.1
- Mod Menu 21.0.0 -> 21.0.1
- Puzzles Lib 26.3.17 -> 26.3.18
- Right Click Harvest 4.6.2 -> 4.7.0
- Sodium 0.9.3-beta.1 -> 0.9.3-beta.5
- SuperMartijn642's Core Lib 1.1.26c -> 1.1.26d
- Veinminer 2.13.0 -> 2.13.1
- Veinminer Client 2.13.0 -> 2.13.1

## [1.2.1] - 2026-11-02
### Updated
- C2ME 0.4.2-alpha.0.106 -> 0.4.2-alpha.0.115
- Collective 8.64 -> 8.73
- Easy Elytra Takeoff 4.6 -> 5.0
- Just Enough Items (JEI) 31.17.0.93 -> 31.17.0.108
- Lithium 0.26.2 -> 0.26.3
- Mezz Config 0.6.9 -> 0.6.10
- Not Enough Animations 1.12.6 -> 1.12.7
- Puzzles Lib 26.3.16 -> 26.3.17
- SuperMartijn642's Core Lib 1.1.25 -> 1.1.26c

### Docs
- The Prism download on the release page is now named `forevercraft.zip`.

## [1.2.0] - 2026-10-25
### Updated
- Fabric Loader 0.19.5 -> 0.20.1.
- 27 mods updated to match the maintained Prism instances, including Fabric API 0.165.0,
  Sodium 0.9.3-beta.1, JEI 31.17, C2ME alpha.0.106, Xaero's Minimap 26.6.2 / World Map 1.47.2
  and Veinminer 2.13.0. Full list in MODLIST.md.
- Photon Shader v1.3b -> v1.4.

### Added
- Unified Xaero Worldmap 2.0.4: everything one player maps (caves and all dimensions included) shows up on
  everyone's world map. Players who were offline get the shared map when they join.
- Resource packs: 3D Bamboo Shoots, 3D crops Revamped, Nautilus 3D, RAY's 3D Ladders,
  RAY's 3D Rails, Remodeled Doors 3D.

### Removed
- Fresh Animations resource pack (it needs the EMF/ETF mods, which aren't in the pack).
- Eclipse Shaders.

### Changed
- Distant Horizons, Sound Physics Remastered and Durability Tooltip are now client-only, so the
  server skips them.
- Cloth Config and YACL stay on both sides (they're server-optional libraries).

### Config
- Xaero's maps: `everyone_tracks_everyone` is on, so every player shows up on everyone's minimap and world map.
- New configs shipped: Easy Anvils and Easy Magic server settings, Boids, and Shulker Box Tooltip.

## [1.1.0] - 2026-10-08
### Changed
- Pack moved to packwiz. Players' Prism instances now update themselves on launch,
  and the server pulls the same pack, so both sides always match.
- Removed personal and leftover files the previous export bundled: `options.txt`
  (it overwrote everyone's keybinds and video settings), `usercache.json`,
  `realms_persistence.json`, `config_modified.zip`, and duplicate Veinminer jars
  left in `config/Veinminer/update/`.

### Contents
- 60 mods, 6 resource packs, 4 shader packs on Minecraft 26.3 / Fabric Loader 0.19.5.
  See [MODLIST.md](MODLIST.md).
