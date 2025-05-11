import SwiftUI
import AppKit

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}

struct ContentView: View {
    @StateObject private var bleService = BLEService()

    @State private var sidebarWidth: CGFloat = 200
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    init() {
        print("ContentView: Initializing view")
    }
    
    var body: some View {
        print("ContentView: Building view body")
        return NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            List {
                Text("Special Functions")
                    .font(.headline)
                Button(action: sendCtrlAltDel) {
                    Label("Ctrl+Alt+Del", systemImage: "keyboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!bleService.isConnected)
                
                Button(action: pasteFromClipboard) {
                    Label("Paste", systemImage: "clipboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!bleService.isConnected)
            }
            .navigationSplitViewColumnWidth(sidebarWidth)
            .background(Color(NSColor.windowBackgroundColor))
        }
        detail: {
            // Main content
            VStack {
                Spacer()
                
                VStack(spacing: 5) {
                    Text("Remote Input Area")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Status:")
                            if bleService.isConnected {
                                Text("Connected")
                                    .foregroundColor(.green)
                            } else if !bleService.isPoweredOn {
                                Text("Bluetooth Off")
                                    .foregroundColor(.red)
                            } else if bleService.isScanning {
                                Text("Scanning...")
                                    .foregroundColor(.yellow)
                            } else if bleService.isConnecting {
                                Text("Connecting...")
                                    .foregroundColor(.orange)
                            } else {
                                Text("Disconnected")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if bleService.isConnected {
                            Text("All the keyboard and mouse input within this area is being sent to the remote device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if !bleService.isPoweredOn {
                            Text("Please turn on Bluetooth to connect to the Remote Input Dongle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if bleService.isScanning {
                            Text("Searching for Remote Input Dongle...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if bleService.isConnecting {
                            Text("Establishing connection to Remote Input Dongle...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text("Remote Input Dongle has been disconnected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(bleService.isConnected ? Color.green : Color.clear, width: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            print("ContentView: View appeared, setting up event monitoring")
            setupEventMonitoring()
        }
        .onChange(of: bleService.isPoweredOn) { isPoweredOn in
            if isPoweredOn {
                print("ContentView: Bluetooth powered on, starting automatic scanning")
                bleService.startScanning()
            }
        }
        .onChange(of: bleService.discoveredDevices) { _ in
            handleNewDeviceDiscovery()
        }
        .onChange(of: bleService.isConnected) { isConnected in
            if isConnected {
                bleService.stopScanning()
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("ContentView: Disconnected, starting automatic scanning")
                    bleService.startScanning()
                }
            }
        }
    }

    private func handleNewDeviceDiscovery() {
        guard !bleService.isConnected else { return }
        
        // Connect to the first discovered device
        if let firstDevice = bleService.discoveredDevices.first {
            print("ContentView: Auto-connecting to discovered device: \(firstDevice.name ?? "Unknown")")
            bleService.connect(to: firstDevice)
            bleService.stopScanning()
        }
    }

    private func setupEventMonitoring() {
        print("ContentView: Setting up event monitoring")

        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            handleModifierEvent(event)
            return event
        }

        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            handleKeyboardEvent(event)
            return nil  // Return nil to prevent system bell sound
        }
        
        NSEvent.addLocalMonitorForEvents(matching: [
                .mouseMoved, 
                .leftMouseDown, .leftMouseUp, 
                .rightMouseDown, .rightMouseUp, 
                .leftMouseDragged, .rightMouseDragged,
                .scrollWheel]) { event in
            handleMouseEvent(event)
            return event
        }
    }
    
    private func handleModifierEvent(_ event: NSEvent) {
        print("ContentView: Handling modifier event: \(event.type), modifierFlags: \(event.modifierFlags.rawValue)")

        let modifierMask = KeyMapping.getModifierMask(from: event.modifierFlags)
        print("ContentView: Modifier mask: \(modifierMask)")

        reportKeyboardEvent(event.modifierFlags, nil)
    }
    
    private func handleKeyboardEvent(_ event: NSEvent) {
        print("ContentView: Handling keyboard event: \(event.type), keycode: \(event.keyCode), " +
            "modifierFlags: \(event.modifierFlags.rawValue)")

        reportKeyboardEvent(event.modifierFlags, Int(event.keyCode))
    }

    private func reportKeyboardEvent(_ modifierFlags: NSEvent.ModifierFlags, _ keyCode: Int?) {
        let modifierMask = KeyMapping.getModifierMask(from: modifierFlags)

        var report: [UInt8] = [modifierMask, 0]
        
        if let keyCode = keyCode {
            if let usbKeyCode = KeyMapping.getKeyCode(fromEvent: keyCode) {
                report[1] = usbKeyCode
                print("ContentView: Usb key code: \(usbKeyCode)")
            }
            else {
                print("ContentView: No usb key code found for keycode: \(keyCode)")
            }
        }
        bleService.sendKeyboardReport(report)
    }

    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }

    private func handleMouseEvent(_ event: NSEvent) {
        // Check if mouse is within the main content area
        guard let window = NSApp.windows.first(where: { $0.isKeyWindow }),
              let contentView = window.contentView else {
            return
        }

        let currentSidebarWidth = columnVisibility == .all ? sidebarWidth : 0
        
        let mainContentFrame = contentView.frame.insetBy(dx: currentSidebarWidth, dy: window.titlebarHeight)
        print("ContentView titlebar height: \(window.titlebarHeight), main content frame: \(mainContentFrame)")

        // Check if mouse is within the main content area
        guard mainContentFrame.contains(event.locationInWindow) else {
            return
        }

        print("ContentView: Handling mouse event: \(event.type), buttons: \(NSEvent.pressedMouseButtons), " +
            "dx: \(event.deltaX), dy: \(event.deltaY)")
        
        if event.type != .scrollWheel {
            let deltaX = Int8(clamp(event.deltaX, min: -128, max: 127))
            let deltaY = Int8(clamp(event.deltaY, min: -128, max: 127))

            let report: [UInt8] = [
                UInt8(NSEvent.pressedMouseButtons),
                UInt8(bitPattern: deltaX),
                UInt8(bitPattern: deltaY)
            ]
            bleService.sendMouseReport(report)
        }
        else {
            let wheelScroll = Int8(clamp(event.deltaY * 10, min: -128, max: 127))
            let wheelPan = Int8(clamp(event.deltaX * 10, min: -128, max: 127))
            let report: [UInt8] = [
                UInt8(NSEvent.pressedMouseButtons),
                0,
                0,
                UInt8(bitPattern: wheelScroll),
                UInt8(bitPattern: wheelPan)
            ]
            bleService.sendMouseReport(report)
        }
    }
    
    private func sendCtrlAltDel() {
        // Send Ctrl+Alt+Del combination
        let report: [UInt8] = [
            UInt8(HIDModifierFlags.LeftCtrl | HIDModifierFlags.LeftAlt),
            HIDKeyCodes.Delete
        ]
        bleService.sendKeyboardReport(report)
        
        // Release all keys after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let releaseReport: [UInt8] = [0, 0]
            bleService.sendKeyboardReport(releaseReport)
        }
    }
    
    private func pasteFromClipboard() {
        guard let string = NSPasteboard.general.string(forType: .string) else { return }
        
        // Process each character with a small delay between them
        for (index, char) in string.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.01) {
                // Convert character to uppercase for key code lookup
                let upperChar = char.uppercased().first
                
                // Get the ASCII value of the character
                if let asciiValue = upperChar?.asciiValue,
                   let keyCode = KeyMapping.getKeyCode(formAscii: asciiValue) {
                    // Send key down
                    let keyDownReport: [UInt8] = [char.isUppercase ? HIDModifierFlags.LeftShift : 0, keyCode]
                    bleService.sendKeyboardReport(keyDownReport)
                    
                    // If this is the last character, send key up after a short delay
                }
                if index == string.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        let keyUpReport: [UInt8] = [0, 0]
                        bleService.sendKeyboardReport(keyUpReport)
                    }
                }
            }
        }
    }
}
