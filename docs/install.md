# Installing the pack

Forever Craft is played through [Prism Launcher](https://prismlauncher.org/). Once installed, the pack
updates itself every time you press **Play**: a small updater window appears for a moment, pulls
whatever changed and then starts the game. You never need to download mods yourself.

[← Back to the README](../README.md)

## Before you start: get Prism Launcher

1. Download and install Prism Launcher from [prismlauncher.org](https://prismlauncher.org/download/).
2. Open it and add your Microsoft account under **Accounts → Manage Accounts → Add Microsoft**.
3. Prism downloads the right Java version by itself the first time you launch, so there's nothing else to install.

## Option 1: import the ready-made instance (easiest)

1. Download `Forever Craft.zip` from the [latest release](https://github.com/hippgroot/forever-craft/releases/latest).
2. In Prism, click **Add Instance → Import**, choose the zip and click **OK**.
3. Check the memory setting (see [Memory](#memory) below), then launch.

The first launch downloads every mod, resource pack and shader, so it takes a minute or two.

## Option 2: set it up by hand

1. In Prism, click **Add Instance** and create **Minecraft 26.3** with the **Fabric** loader, version **0.20.1**.
2. Download [`packwiz-installer-bootstrap.jar`](https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest)
   and put it in the instance's `minecraft` folder (right-click the instance → **Folder**).
3. Right-click the instance → **Edit → Settings → Custom commands**, tick **Custom commands** and paste this
   into **Pre-launch command**:
   ```
   "$INST_JAVA" -jar packwiz-installer-bootstrap.jar https://raw.githubusercontent.com/hippgroot/forever-craft/main/pack.toml
   ```
4. In the same settings window, set up **Java** as described in [Memory](#memory) and [Java arguments](#java-arguments).
5. Launch.

## Memory

The ready-made instance gives Minecraft **10 GB**. Change it under **Edit → Settings → Java → Maximum memory allocation**:

| Your PC's RAM | Set Minecraft to |
|---|---|
| 8 GB | 4–5 GB (lower Distant Horizons' render distance too) |
| 16 GB | 6–8 GB |
| 32 GB or more | 10–12 GB |

More isn't always better. Leave plenty for Windows and anything else you run alongside the game.

## Java arguments

The ready-made instance uses `-XX:+UseZGC` (a garbage collector that avoids stutter) and nothing else. If you set
the instance up by hand, put that in **Edit → Settings → Java → JVM arguments**.

Don't use "Aikar's flags" on the client. They're tuned for servers: they lock the whole heap in up front and
optimize for throughput, while a client wants short, smooth pauses, which is what ZGC is built for.

## Shaders and resource packs

All shader packs and resource packs are downloaded but **none are turned on**. Pick your own:

- **Options → Video Settings → Shader Packs**
- **Options → Resource Packs**

Updates never change your choices, keybinds or video settings.

## Updates

- Updates install automatically the next time you launch. There's nothing to do.
- What changed: [CHANGELOG.md](../CHANGELOG.md) and the [releases page](https://github.com/hippgroot/forever-craft/releases).
- The ready-made zip only ever needs re-importing for a new Minecraft or Fabric version; the release notes will say so.

## Troubleshooting

- **"Mod mismatch" or can't join after an update:** close the game and launch again so the updater can pull the
  latest version. Right after an update goes out, GitHub can take about 5 minutes to serve the new files.
- **The updater shows an error:** usually no internet or GitHub being down. Try again later; if you just want to
  play single-player, you can continue with the version you have.
- **Something's broken and restarting doesn't help:** right-click the instance → **Folder**, delete the `mods`
  folder and the `packwiz.json` file next to it, then launch again. The updater re-downloads everything.
- **Game crashes on start:** send the crash report from `minecraft/crash-reports` (or Prism's log window) to the
  person who runs the server.
