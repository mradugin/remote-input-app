import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var bleService = BLEService()
    @State private var lastMousePosition: NSPoint = .zero
    
    init() {
        print("ContentView: Initializing view")
    }
    
    var body: some View {
        print("ContentView: Building view body")
        return VStack {
            Text("Remote Input")
                .font(.title)
                .padding()
            
            HStack {
                Text("Bluetooth Status:")
                Text(bleService.isPoweredOn ? "Powered On" : "Powered Off")
                    .foregroundColor(bleService.isPoweredOn ? .green : .red)
            }
            
            HStack {
                Text("Scanning Status:")
                Text(bleService.isScanning ? "Scanning" : "Not Scanning")
                    .foregroundColor(bleService.isScanning ? .green : .red)
            }
            
            HStack {
                Text("Connection Status:")
                Text(bleService.isConnected ? "Connected" : "Disconnected")
                    .foregroundColor(bleService.isConnected ? .green : .red)
            }
            
            List(bleService.discoveredDevices, id: \.identifier) { peripheral in
                HStack {
                    Text(peripheral.name ?? "Unknown Device")
                    Spacer()
                    if bleService.isConnected && bleService.connectedPeripheral?.identifier == peripheral.identifier {
                        Text("Connected")
                            .foregroundColor(.green)
                    } else {
                        Button("Connect") {
                            bleService.connect(to: peripheral)
                        }
                        .disabled(bleService.isConnected)
                    }
                }
            }
            .frame(height: 150)
            
            HStack {
                Button(action: {
                    print("ContentView: Scan button pressed")
                    if bleService.isScanning {
                        bleService.stopScanning()
                    } else {
                        bleService.startScanning()
                    }
                }) {
                    Text(bleService.isScanning ? "Stop Scanning" : "Start Scanning")
                }
                
                if bleService.isConnected {
                    Button(action: {
                        print("ContentView: Disconnect button pressed")
                        bleService.disconnect()
                    }) {
                        Text("Disconnect")
                    }
                }
            }
            .padding()
        }
        .frame(width: 400, height: 400)
        .background(Color.gray.opacity(0.1))
        .onAppear {
            print("ContentView: View appeared, setting up event monitoring")
            setupEventMonitoring()
        }
    }
    
    private func setupEventMonitoring() {
        print("ContentView: Setting up event monitoring")
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            handleKeyboardEvent(event)
            return event
        }
        
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp]) { event in
            handleMouseEvent(event)
            return event
        }
    }
    
    private func handleKeyboardEvent(_ event: NSEvent) {
        print("ContentView: Handling keyboard event: \(event.type)")
        
        let modifierFlags = event.modifierFlags.rawValue
        let keyCode = event.keyCode
        
        // Create keyboard report
        var report: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
        
        // Set modifier keys
        report[0] = UInt8(modifierFlags & 0xFF)
        
        // Set key code
        if event.type == .keyDown {
            report[2] = UInt8(keyCode)
        }
        
        bleService.sendKeyboardReport(report)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        print("ContentView: Handling mouse event: \(event.type), dx: \(event.deltaX), dy: \(event.deltaY)")
        
        let currentPosition = event.locationInWindow
        
        // Clamp delta values to Int8 range (-128 to 127)
        let deltaX = Int8(max(min(event.deltaX, 127), -128))
        let deltaY = Int8(max(min(event.deltaY, 127), -128))
        
        // Create mouse report
        var report: [UInt8] = [0, 0, 0, 0]
        
        // Set button states
        if event.type == .leftMouseDown {
            report[0] |= 0x01
        } else if event.type == .rightMouseDown {
            report[0] |= 0x02
        }
        
        // Set movement
        report[1] = UInt8(bitPattern: deltaX)
        report[2] = UInt8(bitPattern: deltaY)
        bleService.sendMouseReport(report)
        
        lastMousePosition = currentPosition
    }
} 