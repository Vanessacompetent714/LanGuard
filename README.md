<div align="center">

# 🛡️ LanGuard

### Wi-Fi off when you're wired. Back on when you're not.

A tiny native macOS menu-bar app that turns **Wi-Fi off the moment a wired LAN link goes up**,
and back **on when you unplug** — wake-aware, per-interface, no admin rights, no shell scripts.

[![macOS](https://img.shields.io/badge/macOS-14%2B-000000?logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5-F05138?logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-MenuBarExtra-0A84FF?logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![CI](https://github.com/roypadina/LanGuard/actions/workflows/ci.yml/badge.svg)](https://github.com/roypadina/LanGuard/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?logo=opensourceinitiative&logoColor=white)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?logo=github)](CONTRIBUTING.md)
[![Stars](https://img.shields.io/github/stars/roypadina/LanGuard?style=social)](https://github.com/roypadina/LanGuard/stargazers)

![LanGuard in the menu bar](docs/screenshots/menubar.png)

</div>

---

## Table of Contents

- [Why](#why)
- [Features](#features)
- [Install](#install)
- [Usage](#usage)
- [How it works](#how-it-works)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)

## Why

macOS keeps Wi-Fi on even when you're docked over Ethernet — wasting an IP lease, adding a
second default route, and leaving an extra radio exposed. LanGuard switches Wi-Fi **off** the
instant a wired link is active and switches it back **on** when the cable's gone. It only acts
on plug/unplug **transitions**, so if you manually flip Wi-Fi back on while docked, it stays on
until you next unplug.

## Features

| | |
|---|---|
| 🔌 **Edge-based** | Acts only on wired plug/unplug transitions — your manual Wi-Fi changes are respected. |
| 😴 **Wake-aware** | A transition that happened while asleep is detected and corrected on wake. |
| 🎛️ **Per-interface** | Pick which wired adapters trigger and which Wi-Fi adapters are controlled. |
| 🧪 **Ignores virtual NICs** | Bridge / VPN / VM adapters (e.g. VMware `vmnet`) are off by default so they can't pin Wi-Fi off. |
| 🔔 **Notifications** | Optional banner whenever Wi-Fi is toggled. |
| 🧭 **Configurable indicator** | Menu-bar shows `LAN` / `Wi-Fi` / `Off` — icon only, icon + label, or label only. |
| ⏸️ **Master switch** | Pause all automatic toggling from the menu. |
| 🚀 **Start at login** | Self-healing login item — re-registers if the app moves; prompts if macOS needs approval. |
| 🔐 **No sudo, no shell** | Wi-Fi power via CoreWLAN, link state via SystemConfiguration. |

## Install

> **Requires macOS 14+.**

### Homebrew

```bash
# (planned) once a tap + signed release are published:
brew install --cask roypadina/tap/languard
```

> Not live yet — see [#brew](https://github.com/roypadina/LanGuard/issues) / the Roadmap.

### Build from source

```bash
git clone https://github.com/roypadina/LanGuard.git
cd LanGuard
xcodebuild -workspace LanGuard.xcworkspace -scheme LanGuard -configuration Release build
# copy the built LanGuard.app from DerivedData into /Applications, then launch it
```

The app lives in the menu bar (no Dock icon). On first launch, click **Allow** on the
notification prompt if you want toggle banners.

## Usage

Click the menu-bar icon for status, the **Auto-toggle** master switch, and **Settings…**.

In **Settings** you can:
- choose which **wired adapters** count as triggers (real adapters on by default, virtual off),
- choose which **Wi-Fi adapters** are controlled,
- toggle **notifications**,
- pick the **menu-bar icon style**,
- enable **Start at login**.

## How it works

```
wired link UP   ─▶  Wi-Fi OFF
wired link DOWN ─▶  Wi-Fi ON
(no edge)       ─▶  leave Wi-Fi alone   ← respects manual override
```

| Component | Role |
|---|---|
| `NetworkMonitor` | `SCDynamicStore` link/IP callbacks + `NSWorkspace` wake notification |
| `WiFiController` | CoreWLAN power on/off (no sudo) |
| `ToggleEngine`   | Edge state machine — dependency-injected, fully unit-tested |
| `InterfaceCatalog` | Enumerate + classify Ethernet/Wi-Fi; flag virtual adapters |
| `LoginItem` | `SMAppService` login item (self-healing) |
| `Notifier` | `UNUserNotificationCenter` banners |

See the [Wiki](https://github.com/roypadina/LanGuard/wiki) for deeper docs and
[`CLAUDE.md`](CLAUDE.md) for the full component map.

## Contributing

PRs welcome! `main` is protected — fork, branch, add tests, and open a PR. See
[CONTRIBUTING.md](CONTRIBUTING.md) and the [Code of Conduct](CODE_OF_CONDUCT.md).

```bash
cd LanGuardPackage && swift test   # pure logic, no hardware needed
```

## Support

If LanGuard saves you some battery and annoyance, you can
[**buy me a coffee on Ko-fi ☕**](https://ko-fi.com/roypadina) — totally optional, always appreciated.

## License

[MIT](LICENSE) © Roy Padina
