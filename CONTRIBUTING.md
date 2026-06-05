# Contributing to LanGuard

Thanks for your interest in improving LanGuard! Contributions of all kinds are welcome —
bug reports, feature ideas, docs, and code.

## Ground rules

- **`main` is protected.** No direct pushes. All changes land via Pull Request and are
  reviewed/merged by the maintainer ([@roypadina](https://github.com/roypadina)).
- Be respectful — see the [Code of Conduct](CODE_OF_CONDUCT.md).
- Keep changes focused. One logical change per PR.

## Getting started

```bash
git clone https://github.com/roypadina/LanGuard.git
cd LanGuard
# run the unit tests (pure logic — no hardware needed)
cd LanGuardPackage && swift test
# build the app
xcodebuild -workspace LanGuard.xcworkspace -scheme LanGuard -configuration Debug build
```

Requirements: macOS 14+, Xcode 15+ (Swift 5 language mode).

## Architecture

All logic lives in the `LanGuardFeature` Swift package (modular, unit-tested). The app
target (`LanGuard/`) is a thin SwiftUI `MenuBarExtra` shell. See [`CLAUDE.md`](CLAUDE.md)
for a component map.

The core decision logic (`ToggleEngine`, `LoginItem`, `InterfaceCatalog`, `MenuState`) is
written as **pure, dependency-injected functions** so it can be tested without real network
hardware. Please keep new logic testable the same way.

## Workflow

1. **Fork** the repo and create a branch: `git checkout -b feature/my-thing`.
2. Make your change. **Add or update tests** under `LanGuardPackage/Tests/`.
3. Run `swift test` — everything must pass.
4. Follow the existing code style (match surrounding code; no force-unwraps in non-test code).
5. Commit with a clear message and open a **Pull Request** against `main`.
6. CI must be green and the maintainer must approve before merge.

## Commit messages

Short imperative summary line, then a blank line and details if needed. Example:

```
Add failover mode (deprioritize Wi-Fi instead of disabling)

Sets network service order instead of powering Wi-Fi off, for users who
want Wi-Fi to stay available as a fallback.
```

## Reporting bugs / requesting features

Use the [issue templates](https://github.com/roypadina/LanGuard/issues/new/choose).
Include your macOS version and the relevant interface names (`networksetup -listallhardwareports`).
