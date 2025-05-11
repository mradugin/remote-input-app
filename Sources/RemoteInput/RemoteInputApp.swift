// Description of the setup:
// Keyboard, Mouse input -> this macOS App -> Bluetooth low-energy -> ESP32 -> USB HID -> Other computer

// Useful links:
// https://github.com/kingo132/BLEVirtualKeyboard
// https://github.com/sean-escaped/TakaKeyboard
// https://gist.github.com/conath/c606d95d58bbcb50e9715864eeeecf07
// https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2

import SwiftUI
import AppKit

@main
struct RemoteInputApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        print("RemoteInputApp: Initializing app")
    }
    
    var body: some Scene {
        print("RemoteInputApp: Creating window scene")
        return WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 300)
                .onAppear {
                    print("RemoteInputApp: ContentView appeared")
                }
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
                //.edgesIgnoringSafeArea(.top)
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
