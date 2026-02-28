import Defaults
import SwiftUI

@main
struct PikaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Default(.appMode) private var appMode
    @Default(.hideMenuBarIcon) private var hideMenuBarIcon

    var body: some Scene {
        MenuBarExtra(isInserted: Binding(
            get: { appMode == .menubar && !hideMenuBarIcon },
            set: { _ in }
        )) {
            PopoverContentView()
                .environmentObject(appDelegate.eyedroppers)
        } label: {
            Image("StatusBarIcon")
                .renderingMode(.template)
        }
        .menuBarExtraStyle(.window)
    }
}
