# Home Assistant (Container) — Railway Template

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/wt39ll)

Home Assistant — the world's most popular home-automation platform — as a one-click Railway template running the **official container image** (`ghcr.io/home-assistant/home-assistant:stable`). Built for **cloud-connected smart homes**: automations, dashboards, scripts, webhooks, and cloud integrations, with all state persisted on a volume.

## Container mode — read this first

This template runs **Home Assistant Container** (the plain official Docker image), not Home Assistant Operating System. What that means for your devices:

| ✅ Works on Railway | ❌ Does not work on Railway |
|---|---|
| **Cloud integrations**: Nabu Casa (Google/Alexa), Philips Hue, TP-Link Kasa/Tapo, Shelly, Tuya cloud, weather, calendars, and hundreds more | **Add-on store** — run companion services (MQTT broker, Zigbee2MQTT, Node-RED) as separate Railway services instead |
| **MQTT** — point it at any external broker reachable over the network (Mosquitto on Railway, EMQX Cloud, HiveMQ…) | **USB/serial radios** — no Zigbee/Z-Wave/Bluetooth dongle passthrough (Zigbee2MQTT on another host + MQTT *does* work) |
| **ESPHome devices** reachable over the network (its API is plain TCP) | **mDNS/LAN discovery** — Railway has no multicast; add integrations **by IP address or account** instead |
| **Webhooks** — your public Railway domain receives them directly (IFTTT, Make, sensors) | **Bluetooth** integrations (no adapter) |
| **HACS** — the community store installs fine (command below) | |

If your devices are Wi-Fi/cloud-first or you mainly want HA's automation engine and dashboards, this fits. If you need a Zigbee USB stick or the add-on store, run Home Assistant OS on a box at home.

## What gets provisioned

| Piece | Detail |
|---|---|
| **Service** | Official `ghcr.io/home-assistant/home-assistant:stable` image, built from the pinned public GitHub repo |
| **Web UI** | Port 8123 exposed on your Railway domain |
| **Volume** | Mounted at `/config` — configuration, automations, integrations, and the recorder database all persist across redeploys |
| **Reverse-proxy config** | Seeded on first boot: Home Assistant trusts Railway's edge (CGNAT range), so the UI works with no manual setup |
| **Healthcheck** | `GET /api/onboarding` — generous timeout for the first-boot database initialization |

## Deploy-form variables

| Variable | Enter | Why |
|---|---|---|
| `PORT` | `8123` | Railway requires the listening port to be declared explicitly; Home Assistant serves on 8123 |
| `TZ` | your IANA timezone (e.g. `Europe/Berlin`) | Time-triggered automations depend on it |

## Setup steps after deploy

1. Open your Railway domain. First boot takes **1–3 minutes** (the database is initialized before the UI answers).
2. The **onboarding wizard** appears — create your own admin user (no credentials are shipped with the template).
3. Add integrations under **Settings → Devices & Services → Add Integration** — by **IP or account** (discovery is unavailable in container mode).
4. Optional — install HACS: `railway ssh` into the service, run `wget -O - https://get.hacs.xyz | bash -`, restart, then add the HACS integration.

## Cost

A single service + volume runs comfortably in the **$5–10/month** range. Home Assistant is RAM-hungrier than it looks if you keep long histories; prune with `recorder: purge_keep_days: 10`.

## Troubleshooting

- **502/blank page right after deploy** — first boot is initializing the database; wait 1–3 minutes and refresh.
- **"Discovery found nothing"** — expected in container mode; add integrations by IP/account.
- **Automations fire at the wrong hour** — match the `TZ` variable (and Home Assistant's general settings) to your home.
- **Upgrading** — the image tag is pinned in the repo's Dockerfile; bump it and redeploy after taking a backup (Settings → System → Backups).

# Deploy and Host

Home Assistant Container deploys on Railway as a single service built from the official upstream image, with a persistent volume at `/config` and the web UI on port 8123 at your Railway domain. Everything that defines your smart home — `configuration.yaml`, `automations.yaml`, the `.storage` directory, and the SQLite recorder database — lives on the volume, so redeploys and upgrades never lose your setup. The template ships a first-boot seed that configures Home Assistant to trust Railway's reverse proxy (required, otherwise every proxied request is rejected) and gives the process a graceful 60-second drain at shutdown so the recorder can checkpoint its database.

## About Hosting

Hosting Home Assistant yourself means your automations, dashboards, and integrations run on infrastructure you control, reachable from anywhere via HTTPS on your Railway domain. You create your own admin account in the onboarding wizard on first visit — nothing is shared with the template author. Expect roughly $5–10/month for the service and volume. Container mode cannot use USB radios or the add-on store, and LAN discovery does not exist in the cloud, so integrations are added by IP address or cloud account; MQTT, ESPHome-over-network, webhooks, Nabu Casa, and HACS all work.

## Why Deploy

The official install paths target a Raspberry Pi at home or a self-managed Docker host; the broken public Railway templates for Home Assistant fail on first boot because they do not handle the reverse-proxy trust config or the port declaration Railway needs. This template fixes both, pins the official image, and provisions the `/config` volume for you — one click gets a reachable onboarding wizard instead of a 400 error. Updates are a redeploy of the same repo, and backups are Home Assistant's built-in tar archives on a persistent volume.

## Common Use Cases

- Cloud-first smart homes (TP-Link Kasa/Tapo, Tuya, Hue cloud, Shelly) that want automations and dashboards without a always-on home server
- Webhook receivers for IFTTT/Make/sensors — your Railway domain accepts them directly
- MQTT-based device fleets using a managed broker (EMQX Cloud, HiveMQ) or a Mosquitto service on Railway
- ESPHome device nodes reachable over the network (the ESPHome API is plain TCP)
- HACS users who want custom cards and community integrations in the cloud
- Remote monitoring and alerting with Home Assistant's notification pipeline

## Dependencies for

A single `home-assistant` service built from `ghcr.io/home-assistant/home-assistant:stable` (pinned tag, source repo attached), one Railway volume mounted at `/config`, and one public domain routing to port 8123. No external databases or brokers are required.

### Deployment Dependencies

- None besides Railway itself — Home Assistant uses its built-in SQLite recorder by default
- Optional: an MQTT broker service or external broker account if your devices need one
- Optional: a Nabu Casa subscription for Google Assistant/Amazon Alexa voice control
- Deploy-form variables: `PORT=8123` (the listening port Railway must route and healthcheck) and `TZ` (your IANA timezone, used by time-triggered automations)
