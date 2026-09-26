import LocalAuthentication
import Observation
import SwiftUI

@MainActor @Observable
final class PrivacySettings {
    @ObservationIgnored @AppStorage("privacy.biometrics") var requireBiometrics = false
    @ObservationIgnored @AppStorage("privacy.ai") var allowsAIProcessing = false
    @ObservationIgnored @AppStorage("privacy.translation") var allowsTranslation = false
    @ObservationIgnored @AppStorage("privacy.analytics") var allowsAnalytics = false
    @ObservationIgnored @AppStorage("privacy.widgetText") var allowsPrivateWidgetText = false
    @ObservationIgnored @AppStorage("privacy.sync") var allowsCloudSync = false
    private(set) var isLocked = false
    var authenticationError: String?

    func lock() { if requireBiometrics { isLocked = true } }

    func unlock() async {
        let context = LAContext()
        do {
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
                authenticationError = String(localized: "lock.unavailable")
                return
            }
            if try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: String(localized: "lock.reason")) {
                isLocked = false
            }
        } catch { authenticationError = error.localizedDescription }
    }
}

struct AppLockView: View {
    @Environment(PrivacySettings.self) private var privacy
    var body: some View {
        ZStack {
            CalmBackground()
            VStack(spacing: StillPathSpacing.md) {
                Image(systemName: "lock.shield").font(.system(size: 48)).foregroundStyle(StillPathColor.sage)
                Text("lock.title").font(.largeTitle.bold())
                Text("lock.message").multilineTextAlignment(.center).foregroundStyle(.secondary)
                Button("lock.unlock") { Task { await privacy.unlock() } }.buttonStyle(PrimaryButtonStyle())
                if let error = privacy.authenticationError { Text(error).font(.footnote).foregroundStyle(.red) }
            }.padding(StillPathSpacing.lg)
        }
    }
}

