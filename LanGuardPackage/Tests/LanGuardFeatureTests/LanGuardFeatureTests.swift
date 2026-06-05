import Testing
import ServiceManagement
@testable import LanGuardFeature

/// Mutable test environment backing ToggleEngine's injected dependencies.
private final class Env {
    var wiredActive: [String] = []
    var auto = true
    var stored: Bool?
    var calls: [(on: Bool, names: [String])] = []

    func engine() -> ToggleEngine {
        ToggleEngine(dependencies: .init(
            activeWiredNames: { self.wiredActive },
            wifiTargets: { ["en0"] },
            setWiFiPower: { on, names in self.calls.append((on, names)) },
            anyWiFiOn: { false },
            autoEnabled: { self.auto },
            saveLastWired: { self.stored = $0 },
            loadLastWired: { self.stored }
        ))
    }
}

@Test func firstRun_wiredUp_turnsWiFiOff() {
    let env = Env(); env.stored = nil; env.wiredActive = ["en8"]
    env.engine().evaluate()
    #expect(env.calls.count == 1)
    #expect(env.calls.first?.on == false)
}

@Test func firstRun_wiredDown_leavesWiFiAlone() {
    let env = Env(); env.stored = nil; env.wiredActive = []
    env.engine().evaluate()
    #expect(env.calls.isEmpty)
}

@Test func edgeUp_turnsWiFiOff() {
    let env = Env(); env.stored = false; env.wiredActive = ["en8"]
    env.engine().evaluate()
    #expect(env.calls.map(\.on) == [false])
}

@Test func edgeDown_turnsWiFiOn() {
    let env = Env(); env.stored = true; env.wiredActive = []
    env.engine().evaluate()
    #expect(env.calls.map(\.on) == [true])
}

@Test func noEdge_respectsManualOverride() {
    // Wired stayed up; user manually re-enabled Wi-Fi. App must not touch it.
    let env = Env(); env.stored = true; env.wiredActive = ["en8"]
    env.engine().evaluate()
    #expect(env.calls.isEmpty)
}

@Test func autoDisabled_neverTouchesWiFi() {
    let env = Env(); env.auto = false; env.stored = false; env.wiredActive = ["en8"]
    env.engine().evaluate()
    #expect(env.calls.isEmpty)
}

@Test func reapply_enforcesAfresh() {
    let env = Env(); env.stored = true; env.wiredActive = ["en8"]
    let engine = env.engine()           // loads prev = true
    engine.reapply()                    // clears edge memory, re-enforces
    #expect(env.calls.map(\.on) == [false])
}

// MARK: - Login-item registration decision

@Test func login_notRegistered_registers() {
    #expect(LoginItem.decide(status: .notRegistered, storedPath: nil, currentPath: "/A") == .register)
}

@Test func login_notFound_reRegisters() {
    #expect(LoginItem.decide(status: .notFound, storedPath: "/A", currentPath: "/A") == .reRegisterMoved)
}

@Test func login_enabledSamePath_none() {
    #expect(LoginItem.decide(status: .enabled, storedPath: "/A", currentPath: "/A") == .none)
}

@Test func login_enabledNoStoredPath_none() {
    // Already enabled, first time recording the path → adopt, don't re-register.
    #expect(LoginItem.decide(status: .enabled, storedPath: nil, currentPath: "/A") == .none)
}

@Test func login_movedWhileEnabled_reRegisters() {
    #expect(LoginItem.decide(status: .enabled, storedPath: "/A", currentPath: "/B") == .reRegisterMoved)
}

@Test func login_movedWhileApprovalPending_reRegisters() {
    #expect(LoginItem.decide(status: .requiresApproval, storedPath: "/A", currentPath: "/B") == .reRegisterMoved)
}
