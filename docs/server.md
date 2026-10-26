# Server setup

The server runs in Docker and installs itself from this repo, the same way the clients do. Every time the
container starts, `start.sh` syncs the pack (skipping client-only mods) and then launches Fabric, so the server
always matches what players have.

[← Back to the README](../README.md)

## What's in the server folder

| File | What it does |
|---|---|
| `compose.yaml` | The Docker service (`forevercraft-server`, Java 25) |
| `start.sh` | Syncs the pack with packwiz, then starts the server |
| `jvm-args.txt` | Java memory and garbage-collector settings |
| `fabric.jar` | The Fabric server launcher (Minecraft 26.3, Loader 0.20.1) |
| `packwiz-installer-bootstrap.jar` | Downloads and updates the pack |
| `console.sh` | Server console over RCON, usable from the host |
| `restart.sh` | Warns players, then restarts the server; meant for cron |

The world, `server.properties`, mods and configs are all created in this same folder.

## Requirements

- A Linux machine with **Docker** and the **Docker Compose plugin**, plus `bash` (for the scripts).
- **RAM:** `jvm-args.txt` gives the server 20 GB, so the machine needs roughly 24 GB or more. Lower `-Xms` and
  `-Xmx` (keep them equal) if you have less.
- **Port 25565/TCP** open to the internet (router port-forward and/or firewall). RCON (25575) stays local only;
  don't forward it.

## First-time setup

1. **Get the files.** Download `forevercraft-server.zip` from the
   [latest release](https://github.com/hippgroot/forever-craft/releases/latest) onto the server and unzip it:
   ```sh
   unzip forevercraft-server.zip
   cd server
   ```
   You can rename the `server` folder to anything you like.

2. **Fix ownership.** The container runs as user `1000:1000`, so the folder must belong to that user:
   ```sh
   sudo chown -R 1000:1000 .
   ```

3. **Accept the Minecraft EULA** ([read it here](https://aka.ms/MinecraftEULA)):
   ```sh
   echo "eula=true" > eula.txt
   ```

4. **Create `server.properties` with RCON turned on.** The scripts read the port and password from this file.
   Minecraft fills in every other setting with defaults on first start, and keeps what you put here:
   ```properties
   enable-rcon=true
   rcon.port=25575
   rcon.password=CHANGE-ME-to-something-long-and-random
   motd=Forever Craft
   ```
   A quick way to make a password: `openssl rand -base64 24`.

5. **Start it:**
   ```sh
   docker compose up -d
   docker compose logs -f forevercraft-server
   ```
   The first start downloads the mods, then generates the world. Once you see `Done (…)! For help, type "help"`,
   press `Ctrl+C` to stop watching the log (the server keeps running).

6. **Make the scripts executable** (zip files don't keep that):
   ```sh
   chmod +x *.sh
   ```

## Day to day

| Task | Command |
|---|---|
| Open the console | `./console.sh` (type `exit` to leave) |
| Run one command | `./console.sh say Hello everyone` |
| Restart with a 5-minute warning | `./restart.sh` |
| Restart with a custom warning | `./restart.sh 15` (minutes; `0` = 10-second countdown only) |
| Stop the server | `docker compose stop` |
| Start it again | `docker compose up -d` |
| Watch the log | `docker compose logs -f forevercraft-server` |

`docker compose stop` shuts the server down cleanly and saves the world. Because of `restart: unless-stopped`,
the server also comes back on its own after a crash or a reboot of the machine.

## Automatic restarts (cron)

`restart.sh` warns players in chat, saves, sends `stop`, and Docker starts the server again. That restart also
pulls any pack update. It only talks to the server over RCON, so it doesn't need Docker permissions.

Open your crontab with `crontab -e` and add (with the real path to the folder):

```
55 5,11,17,23 * * *  bash /path/to/server/restart.sh >> /path/to/server/logs/restart.log 2>&1
```

That starts the 5-minute warning at 5:55, 11:55, 17:55 and 23:55, so the restarts land on 06:00, 12:00, 18:00 and
00:00 (in the machine's time zone). `restart.log` records each restart and whether the server came back.

## Updating

- **Pack updates (mods, configs):** restart the server after the update is pushed to `main`, e.g. `./restart.sh 0`,
  or just let the next scheduled restart pick it up.
- **New Fabric Loader version:** packwiz doesn't update the launcher. Copy `fabric.jar` from the new release's
  `forevercraft-server.zip` over the old one (or download it from
  [fabricmc.net/use/server](https://fabricmc.net/use/server) and rename it to `fabric.jar`), then restart.
- **New Minecraft version:** treat it like a new loader version, and check that `compose.yaml` uses a Java version
  that Minecraft supports.

## Backups

Everything worth keeping is in the folder: the `world` folder, `server.properties`, `ops.json`, `whitelist.json`
and `banned-*.json`. To copy the world safely while the server runs:

```sh
mkdir -p ~/backups
./console.sh save-off
./console.sh save-all flush
tar czf ~/backups/world-$(date +%F).tar.gz world
./console.sh save-on
```

## Troubleshooting

- **`console.sh` says it can't connect:** the server isn't fully started yet, or `enable-rcon`/`rcon.port`/
  `rcon.password` are missing from `server.properties`. Check the log.
- **`Permission denied` errors in the log:** the folder isn't owned by `1000:1000`. Repeat step 2.
- **The container keeps restarting:** run `docker compose logs forevercraft-server`. The usual causes are an
  unaccepted EULA, too little RAM for `jvm-args.txt`, or the pack failing to download (GitHub down, or a typo in
  the pack URL in `start.sh`).
- **Players get "mod mismatch":** they're on an older or newer pack than the server. Restart the server and have
  them relaunch so both sides are on the latest `main`.
