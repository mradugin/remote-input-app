import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var bleService = BLEService()
    
    init() {
        print("ContentView: Initializing view")
    }
    
    var body: some View {
        print("ContentView: Building view body")
        return VStack(spacing: 20) {
            Text("Remote Input")
                .font(.title)
                .padding()
            
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
                            .foregroundColor(.gray)
                    } else if bleService.isConnecting {
                        Text("Connecting...")
                            .foregroundColor(.orange)
                    } else {
                        Text("Disconnected")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .frame(width: 300, height: 200)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
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
        print("ContentView: Handling keyboard event: \(event.type), keycode: \(event.keyCode), modifierFlags: \(event.modifierFlags.rawValue)")

        reportKeyboardEvent(event.modifierFlags, Int(event.keyCode))
    }

    private func reportKeyboardEvent(_ modifierFlags: NSEvent.ModifierFlags, _ keyCode: Int?) {
        let modifierMask = KeyMapping.getModifierMask(from: modifierFlags)

        var report: [UInt8] = [0, 0]
        
        report[0] = modifierMask
        if let keyCode = keyCode {
            if let usbKeyCode = KeyMapping.getKeyCode(from: keyCode) {
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
        // Check if mouse is within the current window
        guard let window = NSApp.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        guard window.frame.contains(window.convertPoint(toScreen: event.locationInWindow)) else {
            return
        }

        print("ContentView: Handling mouse event: \(event.type), buttons: \(NSEvent.pressedMouseButtons), dx: \(event.deltaX), dy: \(event.deltaY)")
        
        if event.type != .scrollWheel {
            // Clamp delta values to Int8 range (-128 to 127)
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
} 