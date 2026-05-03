import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @State private var step: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            switch step {
            case 0: stepWelcome
            case 1: stepLanguage
            case 2: stepAccessibility
            default: stepDone
            }

            Spacer()

            HStack {
                if step > 0 {
                    Button(String(localized: "Back")) { step -= 1 }
                }
                Spacer()
                if step < 3 {
                    Button(String(localized: "Continue")) { step += 1 }
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button(String(localized: "Done")) { finish() }
                        .keyboardShortcut(.defaultAction)
                }
            }
        }
        .padding(24)
        .frame(width: 460, height: 360)
    }

    private var stepWelcome: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles").font(.system(size: 56)).foregroundStyle(.tint)
            Text(String(localized: "Welcome to MacOSAppStarter")).font(.title.bold())
            Text(String(localized: "A short tour of what's included."))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var stepLanguage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Pick a language")).font(.title2.bold())
            Picker(String(localized: "Language"),
                   selection: $localization.languageCode) {
                Text(String(localized: "Follow System")).tag("")
                Text("English").tag("en")
                Text("简体中文").tag("zh-Hans")
            }
            .pickerStyle(.radioGroup)
            Text(String(localized: "You can change this later in Settings."))
                .foregroundStyle(.secondary)
        }
    }

    private var stepAccessibility: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Accessibility")).font(.title2.bold())
            Text(String(localized: "MacOSAppStarter shows a sample Accessibility prompt. Real apps using global hotkeys or window inspection need this."))
                .foregroundStyle(.secondary)
            Button(String(localized: "Open Accessibility Preferences")) {
                AccessibilityChecker.shared.requestPermission()
            }
        }
    }

    private var stepDone: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 56)).foregroundStyle(.green)
            Text(String(localized: "All set")).font(.title.bold())
            Text(String(localized: "Find the app in your menu bar and try the hotkey from Settings → Shortcuts."))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "onboarding.completed")
        Analytics.shared.track("onboarding_completed")
        NSApp.keyWindow?.close()
    }
}
