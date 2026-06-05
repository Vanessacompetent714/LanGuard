import Foundation
import ServiceManagement
import AppKit

/// What registration action a launch needs, given current state.
public enum LoginRegisterDecision: Equatable {
    case none             // already registered for this path — nothing to do
    case register         // not registered yet — register now
    case reRegisterMoved  // registration lost or bundle moved — re-register
}

/// Wraps the "start at login" login-item registration. Self-heals: re-registers
/// automatically when the app bundle moves or the registration is lost, and
/// prompts the user when macOS needs their approval.
public enum LoginItem {

    private static let pathKey = "registeredBundlePath"

    public static var status: SMAppService.Status { SMAppService.mainApp.status }
    public static var isEnabled: Bool { status == .enabled }

    public static var statusDescription: String {
        switch status {
        case .enabled:          return "Enabled"
        case .requiresApproval: return "Needs your approval in System Settings"
        case .notRegistered:    return "Not registered"
        case .notFound:         return "App not found — will re-register"
        @unknown default:       return "Unknown"
        }
    }

    /// Pure decision used by `ensureRegistered` (unit-tested). A `nil` stored path
    /// while already enabled means "first time we're recording it" → no re-register.
    public static func decide(status: SMAppService.Status,
                              storedPath: String?,
                              currentPath: String) -> LoginRegisterDecision {
        switch status {
        case .notRegistered:
            return .register
        case .notFound:
            return .reRegisterMoved
        case .enabled, .requiresApproval:
            return (storedPath == currentPath || storedPath == nil) ? .none : .reRegisterMoved
        @unknown default:
            return .none
        }
    }

    /// Ensure the login item is registered for the CURRENT bundle path.
    /// Auto-registers on first run; re-registers if the app moved or the
    /// registration was lost. Returns the action taken so the caller can prompt.
    @discardableResult
    public static func ensureRegistered() -> LoginRegisterDecision {
        let current = Bundle.main.bundlePath
        let defaults = UserDefaults.standard
        let stored = defaults.string(forKey: pathKey)
        let decision = decide(status: status, storedPath: stored, currentPath: current)

        switch decision {
        case .none:
            // Already enabled but unrecorded → adopt current path silently so a
            // genuine future move is detected.
            if status == .enabled, stored != current {
                defaults.set(current, forKey: pathKey)
            }
            return .none

        case .register, .reRegisterMoved:
            if decision == .reRegisterMoved {
                try? SMAppService.mainApp.unregister()
            }
            do {
                try SMAppService.mainApp.register()
                defaults.set(current, forKey: pathKey)
            } catch {
                NSLog("LanGuard: login item register failed: \(error)")
            }
            return decision
        }
    }

    /// Manual toggle from the Settings window.
    @discardableResult
    public static func setEnabled(_ enabled: Bool) -> Bool {
        let defaults = UserDefaults.standard
        do {
            if enabled {
                try SMAppService.mainApp.register()
                defaults.set(Bundle.main.bundlePath, forKey: pathKey)
            } else {
                try SMAppService.mainApp.unregister()
                defaults.removeObject(forKey: pathKey)
            }
            return true
        } catch {
            NSLog("LanGuard: login item \(enabled ? "register" : "unregister") failed: \(error)")
            return false
        }
    }

    // MARK: - User prompts

    /// If macOS requires the user to approve the login item, prompt + open Settings.
    public static func promptForApprovalIfNeeded() {
        guard status == .requiresApproval else { return }
        runAlert(
            title: "LanGuard needs approval to start at login",
            body: "macOS disabled LanGuard's login item. Open Login Items settings and switch LanGuard back on so it launches automatically.",
            primary: "Open Login Items Settings",
            secondary: "Later"
        ) { SMAppService.openSystemSettingsLoginItems() }
    }

    /// Inform the user that the login item was re-registered after the app moved.
    /// If approval is now required, defer to the approval prompt instead.
    public static func notifyReRegisteredAfterMove() {
        if status == .requiresApproval {
            promptForApprovalIfNeeded()
            return
        }
        runAlert(
            title: "LanGuard updated its login item",
            body: "LanGuard noticed it moved and re-registered to start at login from:\n\(Bundle.main.bundlePath)",
            primary: "OK",
            secondary: nil
        ) {}
    }

    private static func runAlert(title: String,
                                 body: String,
                                 primary: String,
                                 secondary: String?,
                                 action: @escaping () -> Void) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = body
        alert.addButton(withTitle: primary)
        if let secondary { alert.addButton(withTitle: secondary) }
        if alert.runModal() == .alertFirstButtonReturn { action() }
    }
}

/// Removes the legacy shell-based com.roy.wifitoggle LaunchAgent so it doesn't
/// fight the app. Runs once.
public enum LegacyCleanup {

    public static func run() {
        let home = NSHomeDirectory()
        let plist = "\(home)/Library/LaunchAgents/com.roy.wifitoggle.plist"
        let fm = FileManager.default
        guard fm.fileExists(atPath: plist) else { return }

        let bootout = Process()
        bootout.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        bootout.arguments = ["bootout", "gui/\(getuid())/com.roy.wifitoggle"]
        try? bootout.run()
        bootout.waitUntilExit()

        try? fm.removeItem(atPath: plist)
        try? fm.removeItem(atPath: "\(home)/bin/wifi-toggle.sh")
        NSLog("LanGuard: removed legacy com.roy.wifitoggle LaunchAgent")
    }
}
