#!/bin/bash
#
# diy-part1.sh — Inject CMCC RAX3000Q device support into ImmortalWrt
#
# This script adds the RAX3000Q (IPQ5018 + QCA8337) target files into
# the official ImmortalWrt qualcommax/ipq50xx build tree.
# Run BEFORE feeds update.
#

set -euo pipefail

echo "==> Adding CMCC RAX3000Q device support..."

# --- 1. Device Tree Source ---
cat > target/linux/qualcommax/dts/ipq5018-cmcc-rax3000q.dts << 'EODTS'
// SPDX-License-Identifier: GPL-2.0-or-later OR MIT

/dts-v1/;

#include "ipq5018.dtsi"
#include "ipq5018-ess.dtsi"
#include "ipq5018-qcn6122.dtsi"

#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>
#include <dt-bindings/leds/common.h>

/ {
	model = "CMCC RAX3000Q";
	compatible = "cmcc,rax3000q", "qcom,ipq5018";

	aliases {
		serial0 = &blsp1_uart1;
		led-boot = &led_status_green;
		led-failsafe = &led_status_red;
		led-running = &led_status_green;
		led-upgrade = &led_status_blue;
		label-mac-device = <&dp1>;
	};

	chosen {
		bootargs-append = " root=/dev/ubiblock0_1 swiotlb=1 coherent_pool=2M";
		stdout-path = "serial0:115200n8";
	};

	keys {
		compatible = "gpio-keys";
		pinctrl-0 = <&button_pins>;
		pinctrl-names = "default";

		reset-button {
			label = "reset";
			gpios = <&tlmm 23 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};

		mesh-button {
			label = "mesh";
			gpios = <&tlmm 38 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_WPS_BUTTON>;
		};
	};

	leds {
		compatible = "gpio-leds";
		pinctrl-0 = <&led_pins>;
		pinctrl-names = "default";

		led_status_red: led-0 {
			gpios = <&tlmm 24 GPIO_ACTIVE_HIGH>;
			color = <LED_COLOR_ID_RED>;
			function = LED_FUNCTION_STATUS;
			default-state = "off";
		};

		led_status_green: led-1 {
			gpios = <&tlmm 19 GPIO_ACTIVE_HIGH>;
			color = <LED_COLOR_ID_GREEN>;
			function = LED_FUNCTION_STATUS;
			default-state = "off";
		};

		led_status_blue: led-2 {
			gpios = <&tlmm 17 GPIO_ACTIVE_HIGH>;
			color = <LED_COLOR_ID_BLUE>;
			function = LED_FUNCTION_INDICATOR;
			default-state = "off";
		};
	};
};

&sleep_clk {
	clock-frequency = <32000>;
};

&xo_board_clk {
	clock-div = <4>;
	clock-mult = <1>;
};

&blsp1_uart1 {
	status = "okay";

	pinctrl-0 = <&serial_0_pins>;
	pinctrl-names = "default";
};

&crypto {
	status = "okay";
};

&cryptobam {
	status = "okay";
};

&prng {
	status = "okay";
};

&qfprom {
	status = "okay";
};

&qpic_bam {
	status = "okay";
};

&qpic_nand {
	pinctrl-0 = <&qpic_pins>;
	pinctrl-names = "default";
	status = "okay";

	nand@0 {
		compatible = "spi-nand";
		reg = <0>;
		nand-ecc-engine = <&qpic_nand>;
		nand-bus-width = <8>;

		partitions {
			compatible = "qcom,smem-part";

			partition-art {
				label = "0:art";
				read-only;

				nvmem-layout {
					compatible = "fixed-layout";
					#address-cells = <1>;
					#size-cells = <1>;

					macaddr_art_0: macaddr@0 {
						reg = <0x0 0x6>;
					};

					macaddr_art_6: macaddr@6 {
						reg = <0x6 0x6>;
					};

					caldata_art_1000: caldata@1000 {
						reg = <0x1000 0x10000>;
					};

					caldata_art_11000: caldata@11000 {
						reg = <0x11000 0x10000>;
					};
				};
			};
		};
	};
};

&tlmm {
	button_pins: button-state {
		pins = "gpio23", "gpio38";
		function = "gpio";
		drive-strength = <8>;
		bias-pull-up;
	};

	led_pins: led-state {
		pins = "gpio17", "gpio19", "gpio24";
		function = "gpio";
		drive-strength = <8>;
		bias-pull-down;
	};

	mdio1_pins: mdio1-state {
		mdc-pins {
			pins = "gpio36";
			function = "mdc";
			drive-strength = <8>;
			bias-pull-up;
		};

		mdio-pins {
			pins = "gpio37";
			function = "mdio";
			drive-strength = <8>;
			bias-pull-up;
		};
	};
};

&dp1 {
	status = "okay";

	nvmem-cells = <&macaddr_art_0>;
	nvmem-cell-names = "mac-address";
	phy-handle = <&ge_phy>;
	phy-mode = "internal";
};

&dp2 {
	status = "okay";

	nvmem-cells = <&macaddr_art_6>;
	nvmem-cell-names = "mac-address";
	phy-mode = "sgmii";
	managed = "in-band-status";
};

&mdio0 {
	status = "okay";
};

&ge_phy {
	status = "okay";
};

&mdio1 {
	status = "okay";

	pinctrl-0 = <&mdio1_pins>;
	pinctrl-names = "default";

	reset-gpios = <&tlmm 26 GPIO_ACTIVE_LOW>;
	reset-delay-us = <10000>;

	qca8337: switch@0 {
		compatible = "qca,qca8337";
		reg = <0>;

		ports {
			#address-cells = <1>;
			#size-cells = <0>;

			port@1 {
				reg = <1>;
				label = "wan";
			};

			port@2 {
				reg = <2>;
				label = "lan1";
			};

			port@4 {
				reg = <4>;
				label = "lan2";
			};

			port@5 {
				reg = <5>;
				label = "lan3";
			};

			port@6 {
				reg = <6>;
				label = "cpu";
				ethernet = <&dp2>;
				phy-mode = "sgmii";

				fixed-link {
					speed = <1000>;
					full-duplex;
				};
			};
		};
	};
};

&wifi0 {
	status = "okay";
	qcom,ath11k-calibration-variant = "CMCC-RAX3000Q";
	nvmem-cells = <&caldata_art_1000>;
	nvmem-cell-names = "calibration";
};

&wifi1 {
	status = "okay";
	qcom,ath11k-calibration-variant = "CMCC-RAX3000Q";
	nvmem-cells = <&caldata_art_11000>;
	nvmem-cell-names = "calibration";
};
EODTS

echo "    [OK] DTS created"


# --- 2. Add device to image Makefile ---
if ! grep -q "cmcc_rax3000q" target/linux/qualcommax/image/ipq50xx.mk; then
    cat >> target/linux/qualcommax/image/ipq50xx.mk << 'EOMK'

define Device/cmcc_rax3000q
	$(call Device/FitImageLzma)
	$(call Device/UbiFit)
	DEVICE_VENDOR := CMCC
	DEVICE_MODEL := RAX3000Q
	DEVICE_DTS_CONFIG := config@mp02.1
	SOC := ipq5018
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	IMAGE_SIZE := 59392k
	NAND_SIZE := 128m
	DEVICE_PACKAGES := ath11k-firmware-ipq5018-qcn6122 \
		ipq-wifi-cmcc_rax3000q
endef
TARGET_DEVICES += cmcc_rax3000q
EOMK
    echo "    [OK] Image definition added"
else
    echo "    [SKIP] Image definition already present"
fi


# --- 3. Add network board.d config ---
NETWORK_FILE="target/linux/qualcommax/ipq50xx/base-files/etc/board.d/02_network"
if ! grep -q "cmcc,rax3000q" "$NETWORK_FILE"; then
    # Insert RAX3000Q case before the final *) catch-all or at a known insertion point
    sed -i '/cmcc,pz-l8/a\\tcmcc,rax3000q|\\' "$NETWORK_FILE" 2>/dev/null || true
    # If PZ-L8 isn't there, try inserting before the default case
    if ! grep -q "cmcc,rax3000q" "$NETWORK_FILE"; then
        sed -i '/ipq50xx_setup_interfaces/,/esac/ {
            /\*)/{
                i\\tcmcc,rax3000q)\
\t\tucidef_set_interfaces_lan_wan "lan1 lan2 lan3" "wan"\
\t\t;;
            }
        }' "$NETWORK_FILE"
    fi
    echo "    [OK] Network config added"
else
    echo "    [SKIP] Network config already present"
fi


# --- 4. Add LED board.d config (if exists) ---
LEDS_FILE="target/linux/qualcommax/ipq50xx/base-files/etc/board.d/01_leds"
if [ -f "$LEDS_FILE" ] && ! grep -q "cmcc,rax3000q" "$LEDS_FILE"; then
    sed -i '/esac/ i\
cmcc,rax3000q)\
\tucidef_set_led_default "status_green" "STATUS (green)" "green:status" "0"\
\tucidef_set_led_default "status_blue" "STATUS (blue)" "blue:indicator" "0"\
\t;;' "$LEDS_FILE"
    echo "    [OK] LED config added"
fi


echo "==> CMCC RAX3000Q device support injection complete!"
