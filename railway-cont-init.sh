#!/bin/sh
# Railway template first-boot seed.
# Template deploys start with an empty /config volume. Copy the seed files in
# once — never overwriting anything the user already has.
#
# 1) Base YAML files (configuration/automations/scripts/scenes).
# 2) /config/.storage/http — Home Assistant 2026.x configures its HTTP server
#    (incl. reverse-proxy trust) from this store, NOT from configuration.yaml.
#    A YAML http: block would only stage a "pending" trial that auto-reverts
#    after 5 minutes when nobody confirms it (unattended first boot), leaving
#    proxied requests rejected with 400. Seeding the store directly makes the
#    Railway trusted-proxy block (100.64.0.0/10) the stable config from the
#    very first boot.
if [ ! -f "/config/.storage/http" ]; then
    mkdir -p /config/.storage
    cp /seed/http-storage.json /config/.storage/http
    echo "[railway-seed] wrote /config/.storage/http (reverse-proxy trust for Railway edge)"
fi
for f in configuration automations scripts scenes; do
    if [ ! -f "/config/$f.yaml" ]; then
        cp "/seed/$f.yaml" "/config/$f.yaml"
        echo "[railway-seed] wrote /config/$f.yaml"
    fi
done
exit 0
