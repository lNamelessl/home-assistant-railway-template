# Home Assistant Container — official upstream image, pinned tag.
# Upgrades: bump this tag (or pin by digest) and redeploy.
#   Tags: https://github.com/home-assistant/core/pkgs/container/home-assistant
# This is *container* mode: the Home Assistant Core image without the
# Home Assistant Operating System layer (no add-on store, no device passthrough).
FROM ghcr.io/home-assistant/home-assistant:stable

# Seed files copied into /config on FIRST boot only (see railway-cont-init.sh):
# base YAML files plus .storage/http with the reverse-proxy trust block for
# Railway's edge (100.64.0.0/10) — HA 2026.x configures HTTP from that store,
# not from configuration.yaml (a YAML http: block would stage a pending trial
# that auto-reverts after 5 min on unattended first boots).
COPY seed/ /seed/
COPY railway-cont-init.sh /etc/cont-init.d/50-railway-seed.sh
RUN chmod +x /etc/cont-init.d/50-railway-seed.sh

# The upstream image ships no EXPOSE. Railway needs it to resolve the port it
# healthchecks and routes to (no EXPOSE -> probes hit the default port and
# every deployment fails its healthcheck while Home Assistant is healthy).
EXPOSE 8123

# Notes:
# - Serves the web UI on port 8123 (exposed on the Railway domain).
# - All persistent state (configuration.yaml, automations.yaml, .storage,
#   SQLite recorder DB) lives under /config — attach a Railway volume there.
# - On ARM64 hosts with >4K memory pages, set env var DISABLE_JEMALLOC=true
#   if the container logs "<jemalloc>: Unsupported system page size".
