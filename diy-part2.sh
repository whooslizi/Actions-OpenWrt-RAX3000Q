#!/bin/bash
#
# diy-part2.sh — Post-feeds customization
#
# Run AFTER feeds install. Use this for additional package tweaks,
# theme changes, or config modifications.
#

set -euo pipefail

echo "==> Applying post-feeds customizations..."

# Example: change default theme, add packages, etc.
# Uncomment and modify as needed:
#
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

echo "==> Post-feeds customization complete!"
