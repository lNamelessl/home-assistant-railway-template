# Home Assistant Container — official upstream image, pinned tag.
# Upgrades: bump this tag (or pin by digest) and redeploy.
#   Tags: https://github.com/home-assistant/core/pkgs/container/home-assistant
# This is *container* mode: the Home Assistant Core image without the
# Home Assistant Operating System layer (no add-on store, no device passthrough).
FROM ghcr.io/home-assistant/home-assistant:stable

# Notes:
# - Serves the web UI on port 8123 (exposed on the Railway domain).
# - All persistent state (configuration.yaml, automations.yaml, .storage,
#   SQLite recorder DB) lives under /config — attach a Railway volume there.
# - On ARM64 hosts with >4K memory pages, set env var DISABLE_JEMALLOC=true
#   if the container logs "<jemalloc>: Unsupported system page size".
