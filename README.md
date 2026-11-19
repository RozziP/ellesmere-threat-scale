# Ellesmere Threat Scale

Ellesmere Threat Scale is a WoW Forever companion addon for EllesmereUI Nameplates. It changes the visual size of each enemy nameplate as your aggro changes.

| Your aggro on the enemy | Size relative to EllesmereUI |
| --- | ---: |
| Holding aggro securely | 75% |
| Losing aggro, while the enemy is still attacking you | 115% |
| No aggro, with a reported threat state | 130% |

Scaling follows your own threat and works without a tank role assignment. The multiplier combines with EllesmereUI’s target, cast, and enemy-type scaling, and transitions use the host’s animation. Out-of-combat units and enemies without readable threat data use their normal EllesmereUI scale.

## Install

1. Keep [**EllesmereUI**](https://www.curseforge.com/wow/addons/ellesmereui) and its **Nameplates** module installed and enabled on WoW Forever.
2. Download the `-forever.zip` attachment from the [latest release](https://github.com/RozziP/ellesmere-threat-scale/releases/latest) and extract it into the game’s `_forever_/Interface/AddOns` folder. The resulting path should end in `AddOns/EllesmereThreatScale/EllesmereThreatScale.toc`.
3. Fully restart WoW and make sure **Ellesmere Threat Scale** is enabled in the AddOns list.

In WowUp, select **WoW Forever** and paste the [repository URL](https://github.com/RozziP/ellesmere-threat-scale) into **Get Addons → Install from URL**.

## Settings

Open `/eui` and select **Threat Scale → Nameplates** in the sidebar. EUI puts companion settings in their own sections. Use **Enable Threat Scaling** to turn the effect on or off, and adjust the three aggro states from 50% to 200% of the current EllesmereUI size. Changes apply to visible enemy plates as you make them.

Settings are account-wide and saved by the companion addon. Use the page's **Reset** button to restore the defaults.

Built against EllesmereUI 9.9 and WoW Forever 1.60.1 (interface 16001). This is an independent companion addon. It uses EllesmereUI Nameplates’ internal scale animation, so future versions of EllesmereUI may require an update.
