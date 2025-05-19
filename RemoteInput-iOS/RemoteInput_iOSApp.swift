import SwiftUI
import OSLog

@main
struct RemoteInputApp: App {
    init() {
        Logger.app.trace("Initializing app")
    }
    
    var body: some Scene {
        Logger.app.trace("Creating window scene")
        return WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 300)
                .onAppear {
                    Logger.app.trace("ContentView appeared")
                }
                .onDisappear {
                    #if os(macOS)
                    NSApplication.shared.terminate(nil)
                    #endif
                }
        }
        .commands {
            SidebarCommands()
        }
    }
}
