# Changelog

All notable changes to LanGuard are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-05

### Added
- **Edge-based Wi-Fi toggling** — turns Wi-Fi off when a wired LAN link goes up and back on
  when it goes down, acting only on plug/unplug transitions so manual changes are respected.
- **Wake-aware** state reconciliation — a transition that happened during sleep is corrected on wake.
- **Per-interface configuration** — choose which wired adapters trigger and which Wi-Fi
  adapters are controlled; new real adapters are auto-included.
- **Virtual-adapter handling** — bridge / VPN / VM adapters (e.g. VMware `vmnet`) are listed
  but off by default (opt-in), so they can't pin Wi-Fi off.
- **Optional notifications** when Wi-Fi is toggled.
- **Configurable menu-bar indicator** — `LAN` / `Wi-Fi` / `Off`, as icon, icon + label, or label.
- **Master pause switch** to disable all automatic toggling.
- **Start at login** via a self-healing `SMAppService` login item that re-registers if the app moves.
- **Homebrew cask** install: `brew install --cask roypadina/tap/languard`.

### Notes
- macOS 14 (Sonoma) or later.
- Ad-hoc signed, not notarized — first launch requires right-click → Open (or clearing quarantine).

[Unreleased]: https://github.com/roypadina/LanGuard/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/roypadina/LanGuard/releases/tag/v1.0.0
