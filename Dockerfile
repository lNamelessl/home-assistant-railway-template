# Home Assistant Container — official upstream image, pinned tag.
# Upgrades: bump this tag (or pin by digest) and redeploy.
#   Tags: https://github.com/home-assistant/core/pkgs/container/home-assistant
# This is *container* mode: the Home Assistant Core image without the
# Home Assistant Operating System layer (no add-on store, no device passthrough).
FROM ghcr.io/home-assistant/home-assistant:stable

# Seed files copied into /config on FIRST boot only (see railway-cont-init.sh):
# a minimal configuration.yaml with the reverse-proxy trust block Railway
# requires, plus empty automations/scripts/scenes includes.
COPY seed/ /seed/
COPY railway-cont-init.sh /etc/cont-init.d/50-railway-seed.sh
RUN chmod +x /etc/cont-init.d/50-railway-seed.sh

# Notes:
# - Serves the web UI on port 8123 (exposed on the Railway domain).
# - All persistent state (configuration.yaml, automations.yaml, .storage,
#   SQLite recorder DB) lives under /config — attach a Railway volume there.
# - On ARM64 hosts with >4K memory pages, set env var DISABLE_JEMALLOC=true
#   if the container logs "<jemalloc>: Unsupported system page size".
