// Description of the setup:
// Keyboard, Mouse input -> this macOS App -> Bluetooth low-energy -> ESP32 -> USB HID -> Other computer

// Useful links:
// https://github.com/kingo132/BLEVirtualKeyboard
// https://github.com/sean-escaped/TakaKeyboard
// https://gist.github.com/conath/c606d95d58bbcb50e9715864eeeecf07
// https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2

import SwiftUI
import OSLog

@main
struct RemoteInputApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        Logger.app.trace("Initializing app")
    }
    
    var body: some Scene {
        Logger.app.trace("Creating window scene")
        return WindowGroup {
            ContentView()
                .frame(minWidth: 700, minHeight: 500)
                .onAppear {
                    Logger.app.trace("ContentView appeared")
                }
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}
