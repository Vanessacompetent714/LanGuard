import Foundation
import AppKit

/// File logger gated by the `debugLoggingEnabled` setting.
///
/// Off by default. When the user turns on **Settings → Debug → Enable debug
/// logging**, events are appended to `~/Library/Logs/LanGuard/languard.log`
/// (rotated at ~1 MB, one backup kept). The intent: a user hitting a problem
/// flips this on, reproduces it, then sends us the file.
///
/// `write` is a cheap no-op while logging is off, so call sites can log freely.
public enum Log {

    /// UserDefaults key — kept in sync with `AppSettings.debugLoggingEnabled`.
    public static let enabledKey = "debugLoggingEnabled"

    private static let queue = DispatchQueue(label: "com.roy.languard.log")
    private static let maxBytes = 1_000_000

    public static var isEnabled: Bool { UserDefaults.standard.bool(forKey: enabledKey) }

    public static var directory: URL {
        let lib = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library")
        return lib.appendingPathComponent("Logs/LanGuard", isDirectory: true)
    }

    public static var fileURL: URL { directory.appendingPathComponent("languard.log") }

    /// Append a timestamped line if debug logging is enabled.
    public static func write(_ message: String) {
        guard isEnabled else { return }
        let stamp = timestamp()
        queue.async {
            let line = "\(stamp)  \(message)\n"
            guard let data = line.data(using: .utf8) else { return }
            let fm = FileManager.default
            try? fm.createDirectory(at: directory, withIntermediateDirectories: true)
            rotateIfNeeded()
            if fm.fileExists(atPath: fileURL.path), let handle = try? FileHandle(forWritingTo: fileURL) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            } else {
                try? data.write(to: fileURL)
            }
        }
    }

    private static func rotateIfNeeded() {
        let fm = FileManager.default
        guard let attrs = try? fm.attributesOfItem(atPath: fileURL.path),
              let size = attrs[.size] as? Int, size > maxBytes else { return }
        let backup = directory.appendingPathComponent("languard.1.log")
        try? fm.removeItem(at: backup)
        try? fm.moveItem(at: fileURL, to: backup)
    }

    private static func timestamp() -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: Date())
    }

    // MARK: - UI helpers

    /// Reveal the log file (or its folder) in Finder — used by the "send us your logs" flow.
    public static func revealInFinder() {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } else {
            NSWorkspace.shared.open(directory)
        }
    }

    /// Delete the current log and its backup.
    public static func clear() {
        queue.async {
            let fm = FileManager.default
            try? fm.removeItem(at: fileURL)
            try? fm.removeItem(at: directory.appendingPathComponent("languard.1.log"))
        }
    }
}
