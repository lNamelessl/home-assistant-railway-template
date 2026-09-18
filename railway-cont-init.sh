#!/bin/sh
# Railway template first-boot seed.
# Home Assistant behind Railway needs a reverse-proxy trust block in
# configuration.yaml (see seed/configuration.yaml). Template deploys start
# with an empty /config volume, so copy the seed files in once — never
# overwriting anything the user already has.
for f in configuration automations scripts scenes; do
    if [ ! -f "/config/$f.yaml" ]; then
        cp "/seed/$f.yaml" "/config/$f.yaml"
        echo "[railway-seed] wrote /config/$f.yaml"
    fi
done
exit 0
