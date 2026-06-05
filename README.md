# LanGuard

A tiny macOS menu-bar app that turns **Wi-Fi off when a wired LAN link is up**, and back
**on when you unplug** — including after sleep. Native Swift, no admin rights, no shell scripts.

![menu bar: LAN](https://img.shields.io/badge/menu%20bar-LAN%20%2F%20Wi--Fi-blue) ![macOS 14+](https://img.shields.io/badge/macOS-14%2B-black) ![MIT](https://img.shields.io/badge/license-MIT-green)

## Why

macOS keeps Wi-Fi on even when you're docked over Ethernet — wasting an IP, adding a second
route, and a minor security/exposure surface. LanGuard switches Wi-Fi off the moment a wired
link is active and restores it when the cable's gone.

## Features

- **Edge-based toggling** — acts only on wired plug/unplug transitions, so a manual Wi-Fi change
  is respected until the next unplug/replug.
- **Wake-aware** — a transition that happened while asleep is detected and corrected on wake.
- **Per-interface config** — choose which wired adapters count as triggers and which Wi-Fi
  adapters to control. New real adapters are auto-included.
- **Ignores virtual adapters** — bridge / VPN / VM (e.g. VMware `vmnet`) adapters are off by
  default, so they can't pin Wi-Fi off forever (opt them in if you want).
- **Notifications** — optional banner whenever Wi-Fi is toggled.
- **Configurable menu-bar indicator** — icon only / icon + label / label only (LAN · Wi-Fi · Off).
- **Master switch** — pause all automatic toggling from the menu.
- **Start at login** — self-healing login item (auto re-registers if the app moves; prompts
  if macOS needs approval).
- **No sudo, no shell** — Wi-Fi power via CoreWLAN, link state via SystemConfiguration.

## Install

Requires macOS 14+.

```bash
git clone https://github.com/roypadina-reeco/LanGuard.git
cd LanGuard
xcodebuild -workspace LanGuard.xcworkspace -scheme LanGuard -configuration Release build
# copy the built LanGuard.app into /Applications, then launch it
```

The app lives in the menu bar (no Dock icon). Click the icon for status, the master toggle,
and **Settings…**. On first launch, click **Allow** on the notification permission prompt if
you want toggle banners.

## How it works

| Piece | Role |
|---|---|
| `NetworkMonitor` | `SCDynamicStore` link/IP callbacks + wake notification |
| `WiFiController` | CoreWLAN power on/off |
| `ToggleEngine`   | edge state machine (wired up → off, down → on) |
| `InterfaceCatalog` | enumerate + classify Ethernet/Wi-Fi, flag virtual adapters |
| `LoginItem` | SMAppService login item (self-healing) |

## License

MIT — see [LICENSE](LICENSE).
