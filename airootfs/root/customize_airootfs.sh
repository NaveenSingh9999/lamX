#!/usr/bin/env bash
# runs inside the ISO root after the overlay lands, before boot images ship
# rebuilds initramfs with airootfs mkinitcpio.conf.d hooks (archiso live boot)
set -euo pipefail
mkinitcpio -P
