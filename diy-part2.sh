#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
sed -i 's/ImmortalWrt/RAX3000Q/g' package/base-files/files/bin/config_generate
sed -i 's/default-settings-chn/default-settings/g' package/base-files/files/bin/config_generate 2>/dev/null || true

# Force-enable all wireless radios on first boot (OpenWrt defaults them to disabled)
# The 5GHz QCN6122 radio often fails to start when channel is "auto" (DFS issue)
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-enable-wifi <<'WIFIEOF'
#!/bin/sh
# Regenerate wireless config from hardware detection if no radios exist yet
if ! uci -q get wireless.radio0 >/dev/null 2>&1; then
    wifi config
fi

# Enable all radios and set safe defaults
uci -q batch <<-EOT
	set wireless.radio0.disabled='0'
	set wireless.radio0.country='US'
	set wireless.radio1.disabled='0'
	set wireless.radio1.country='US'
	set wireless.radio1.channel='36'
	commit wireless
EOT

wifi reload
WIFIEOF
chmod +x files/etc/uci-defaults/99-enable-wifi
