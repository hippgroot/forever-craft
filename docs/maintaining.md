# Maintaining the pack

This repo is a [packwiz](https://packwiz.infra.link/) pack. It doesn't contain any mod jars, only small
`.pw.toml` files that say where each file comes from and what its hash should be. Players and the server
download the real files themselves through packwiz-installer.

[← Back to the README](../README.md)

## How it fits together

| File / folder | Purpose |
|---|---|
| `pack.toml` | Pack name, version, Minecraft and Fabric versions |
| `index.toml` | Every file in the pack with its hash (rebuilt by `packwiz refresh`) |
| `mods/`, `resourcepacks/`, `shaderpacks/` | One `.pw.toml` per project |
| `config/` | Config files shipped to players and the server |
| `.packwizignore` | Repo files that are **not** part of the pack (docs, server folder, zips…) |
| `server/` | Docker setup for the server ([server guide](server.md)) |
| `prism/` | The Prism instance that becomes `Forever Craft.zip` |

Clients and the server read `pack.toml` from the `main` branch on every launch:
`https://raw.githubusercontent.com/hippgroot/forever-craft/main/pack.toml`

## Getting packwiz

Download a build from the [packwiz releases / Actions page](https://github.com/packwiz/packwiz), or install it with Go:

```sh
go install github.com/packwiz/packwiz@latest
```

On Windows you can drop `packwiz.exe` in the repo root. It's already in `.gitignore`.

## Branches

- **`main`** is what everyone plays. Only merge into it when a version is ready.
- **`dev`** is where you work. Nothing there reaches players or the server.

## Common tasks

Run these from the repo root:

| Task | Command |
|---|---|
| Add a mod | `packwiz modrinth add <slug-or-url>` |
| Add a resource pack / shader | `packwiz modrinth add <slug>` (packwiz puts it in the right folder) |
| Update one mod | `packwiz update <name>` |
| Update everything | `packwiz update --all` |
| Remove a mod | `packwiz remove <name>` |
| Change the Fabric Loader | `packwiz migrate loader latest` |
| Rebuild the index | `packwiz refresh` |

After any manual edit (a config file, a `.pw.toml`), run `packwiz refresh` before committing. If the index is
stale, nobody gets the change.

### Client-only vs. server mods

Each `.pw.toml` has a `side`:

- `side = "both"`: installed on clients and the server.
- `side = "client"`: skipped by the server (Sodium, Iris, Zoomify and other purely visual or input mods).
- `side = "server"`: server only.

Edit the line by hand, then run `packwiz refresh`. Distant Horizons and Sound Physics Remastered are deliberately
client-only to save server CPU.

### Configs

Put the file under `config/` and run `packwiz refresh`. By default a config is replaced on everyone's game
whenever you change it in the pack. To ship it only once, so players' own changes stick, add `preserve = true` under that file's entry in
`index.toml`. Most configs in this pack are already set up that way.

### Mods stored in the repo

Unified Xaero Worldmap isn't downloadable by packwiz (its author blocks third-party downloads), so its jar
lives in `mods/` and players download it from this repo instead. Its CC0 license allows that. To update it:

1. Download the new Fabric jar for 26.3 from its
   [CurseForge files page](https://www.curseforge.com/minecraft/mc-mods/unified-xaero-worldmap/files).
2. Put it in `mods/`, delete the old jar, and run `packwiz refresh`.

`packwiz update` doesn't know about it, so check for new versions by hand now and then.

## Testing before release

Point a spare Prism instance at your work instead of `main`, using one of these as its pre-launch URL:

- **Your `dev` branch:** `https://raw.githubusercontent.com/hippgroot/forever-craft/dev/pack.toml` (push first).
- **Local, no push needed:** run `packwiz serve` in the repo and use `http://localhost:8080/pack.toml`.

## Releasing a new version

1. On `dev`: make the changes, run `packwiz refresh`, and test.
2. Bump `version` in `pack.toml` and add an entry to `CHANGELOG.md` (there's a template at the top).
   Update `MODLIST.md` if mods were added, removed or updated.
3. Run `packwiz refresh` once more, commit, then merge `dev` into `main` and push.
4. Tag the commit on `main` and push the tag. The tag must be `v` + the version in `pack.toml`:
   ```sh
   git tag v1.2.0
   git push origin v1.2.0
   ```
5. The **Release draft** workflow (`.github/workflows/release.yaml`) then runs on GitHub. It:
   - fails if the tag doesn't match `pack.toml`, or if `index.toml` is out of date
   - builds **`Forever Craft.zip`** from the `prism/` folder and **`forevercraft-server.zip`** from the `server/`
     folder, adding the latest packwiz bootstrap jar to both
   - creates a **draft** release with both zips and that version's `CHANGELOG.md` section as the notes
6. Check the draft on the [releases page](https://github.com/hippgroot/forever-craft/releases) and click **Publish**.
7. Restart the server (`./restart.sh` on the host) so it picks up the new version.

If the workflow fails, fix the problem, then move the tag to the new commit and push it again:
`git tag -f v1.2.0 && git push -f origin v1.2.0`.

GitHub caches raw files for about 5 minutes, so a player launching right after the push might get the old
version once.

## The Prism and server zips

The release workflow builds both zips from the repo, so there's nothing to zip by hand. Neither holds mods,
only setup. The jars aren't stored in the repo: the workflow downloads the latest packwiz bootstrap into both
zips, and the Fabric server launcher (as `server/fabric.jar`) for the Minecraft and Fabric versions in
`pack.toml`.

- **`Forever Craft.zip`** comes from `prism/`:
  - `instance.cfg`: memory (`MaxMemAlloc`), Java arguments (`JvmArgs`) and the pre-launch command
  - `mmc-pack.json`: the Minecraft and Fabric Loader versions
  - `icon.png`, `.packignore`

  For a new Fabric or Minecraft version, the easiest way to update `mmc-pack.json` is to change the version
  in a Prism instance, export it, and copy the new `mmc-pack.json` over. Don't add a `JavaPath` line to
  `instance.cfg`, since it would point at a folder on your PC.
- **`forevercraft-server.zip`** comes from `server/`. Commit changes there before tagging. A new loader version
  needs nothing extra: bump `fabric` in `pack.toml` and the workflow fetches the matching `fabric.jar`.

The `zips/` folder is ignored by both git and packwiz, so it's a safe place for local copies.
