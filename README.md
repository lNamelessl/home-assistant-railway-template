# Home Assistant on Railway (Container mode)

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/home-assistant-template)

[Home Assistant](https://www.home-assistant.io/) — the world's biggest home-automation platform — as a one-click Railway template, running the **official container image** (`ghcr.io/home-assistant/home-assistant:stable`). Built for **cloud-connected smart homes**: automations, dashboards, scripts, webhooks, and cloud integrations, with everything persisted on a volume.

## Container mode — read this first

This template runs **Home Assistant Container** (the plain Docker image), not Home Assistant Operating System. That changes *which integrations can reach your devices*:

| ✅ Works on Railway | ❌ Does not work on Railway |
|---|---|
| **Cloud integrations**: Nabu Casa, Philips Hue (cloud/bridge reachable over network), TP-Link Kasa/Tapo (cloud + LAN-over-network), Shelly, Tuya cloud, Google Assistant/Amazon Alexa via Nabu Casa, weather, calendars, and hundreds more | **Add-on store** — no apps; run companion services (MQTT broker, Zigbee2MQTT, Node-RED, Esphome dashboard…) as separate Railway services or elsewhere |
| **MQTT** — point it at any **external broker** over the network (e.g. a Mosquitto service on Railway; EMQX Cloud, HiveMQ, etc.) | **USB / serial radios** — no Zigbee/Z-Wave/Bluetooth dongle passthrough. (Zigbee2MQTT/Z-Wave-JS-UI on another host + MQTT *does* work) |
| **ESPHome devices** — any ESPHome node reachable over the network (its API is TCP) | **Host networking / mDNS discovery** — Railway has no L2/multicast, so automatic LAN discovery finds nothing; add integrations by **IP address or account** instead |
| **Webhooks** — manual/webhook triggers are reachable on your public Railway domain, great for IFTTT/Make/webhook-capable sensors | **Bluetooth** integrations (no adapter) |
| **HACS** (Home Assistant Community Store) — install command below | |
| Automations, scripts, scenes, dashboards (Lovelace), templates, Node-RED-style logic, SQLite recorder/history/logbook | |

If your devices are Wi-Fi/cloud-first (Kasa, Tuya, Hue cloud, Shelly cloud, ESPHome over Wi-Fi) or you mainly want HA's automation engine and dashboards, container mode is a great fit. If you need a Zigbee USB stick or the add-on store, run Home Assistant OS on a box at home instead.

## What you get on deploy

| Piece | Detail |
|---|---|
| **Service** | Official `ghcr.io/home-assistant/home-assistant:stable` image (pinned tag in the Dockerfile — bump it to upgrade) |
| **Web UI** | Port **8123** published on your Railway domain |
| **Volume** | Mounted at **`/config`** — `configuration.yaml`, `automations.yaml`, `.storage/`, integrations, and the SQLite recorder database all persist across redeploys |
| **`TZ` variable** | Your IANA timezone (e.g. `Europe/Berlin`) — time-triggered automations depend on it |
| **Healthcheck** | `GET /` with a generous 600 s budget — first boot initializes the database before the UI answers |
| **Graceful shutdown** | ~60 s drain so the recorder can checkpoint its SQLite database cleanly on every restart/redeploy |
| **`DISABLE_JEMALLOC`** | Not set by default. Only on ARM64 hosts with >4K pages, set it to `true` if logs show `<jemalloc>: Unsupported system page size` (not needed on Railway x86) |

## Setup flow (no credentials shipped — you create your own admin)

1. **Deploy**, then open your Railway domain. First boot takes **1–3 minutes** (Home Assistant creates its `.storage` scaffolding and initializes the database before the UI answers — the healthcheck accounts for this; don't panic if the page loads blank at first).
2. The **onboarding wizard** appears: create your admin user (username + password — they exist only in your instance).
3. Set your location/unit preferences when asked, then integrate devices: **Settings → Devices & Services → Add Integration** — search for your platform and add it **by IP or account** (discovery is unavailable in container mode).
4. Create your first automation: **Settings → Automations & Scenes → Create Automation**, or drop YAML into `automations.yaml` and hit **Reload Automations**.

## Installing HACS (optional, container-safe)

HACS works in container mode. Open a shell into the running container and run the official installer against `/config`:

```bash
railway ssh   # from this project's folder, then:
wget -O - https://get.hacs.xyz | bash -
```

Restart Home Assistant (Deploy → Restart, or Settings → System → Restart), then add the **HACS** integration under Devices & Services (it will ask for your GitHub token — HACS-specific, not a Railway credential).

## A 60-second first automation (time-based)

Settings → Automations & Scenes → Create Automation → **Time** → pick a time → Action: **Call a service** → `notify.persistent_notification` with "Hello from Railway". Save, toggle **Run** to test — the trace shows it evaluated. It survives redeploys because it lives in `automations.yaml` on the volume.

## Backups

Everything that matters is in **`/config`** on the attached volume:

- Home Assistant's built-in backups (**Settings → System → Backups**) create a single `.tar` you can download — do this before upgrades.
- Railway keeps volume backups on paid plans; the container itself is stateless, so redeploying the service never loses configuration.

## Cost

A single service + volume runs comfortably in the **$5–10/month** range. Home Assistant is RAM-hungrier than it looks (recorder history grows); if you keep long histories, add RAM or prune the recorder (`recorder: purge_keep_days: 10` in `configuration.yaml`).

## Troubleshooting

- **"502 / blank page right after deploy"** — first boot is initializing the database; wait 1–3 minutes and refresh.
- **Time-based automations fire at the wrong hour** — the `TZ` variable and the timezone in Home Assistant's general settings should both match your home.
- **"Discovery found nothing"** — expected in container mode; add integrations by IP/account (see the table above).
- **Database corruption warnings in logs** — shouldn't happen: the template gives Home Assistant ~60 s to checkpoint cleanly at shutdown. If you force-killed a deploy mid-write, restore from a backup.
- **Upgrading** — bump the tag in the Dockerfile and redeploy; back up first.

## Local development / self-hosting parity

The service is just the official image: `docker run -d --name homeassistant -e TZ=... -v ha_config:/config -p 8123:8123 ghcr.io/home-assistant/home-assistant:stable`. Your `/config` folder is portable in both directions.
