import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var bleService = BLEService()
    
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
        .onChange(of: bleService.isPoweredOn) { isPoweredOn in
            if isPoweredOn {
                print("ContentView: Bluetooth powered on, starting automatic scanning")
                startAutomaticScanning()
            }
        }
        .onChange(of: bleService.discoveredDevices) { _ in
            handleNewDeviceDiscovery()
        }
        .onChange(of: bleService.isConnected) { isConnected in
            if !isConnected {
                // Resume scanning when disconnected, but only if Bluetooth is powered on
                if bleService.isPoweredOn {
                    bleService.startScanning()
                }
            }
        }
    }
    
    private func startAutomaticScanning() {
        guard bleService.isPoweredOn else {
            print("ContentView: Bluetooth not powered on, waiting before starting scan")
            return
        }
        print("ContentView: Starting automatic scanning")
        bleService.startScanning()
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
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
            handleKeyboardEvent(event)
            return event
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
    
    private func handleKeyboardEvent(_ event: NSEvent) {
        print("ContentView: Handling keyboard event: \(event.type)")
        
        let modifierFlags = event.modifierFlags.rawValue
        let keyCode = event.keyCode
        
        var report: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
        
        report[0] = UInt8(modifierFlags & 0xFF)
        if event.type == .keyDown {
            report[2] = UInt8(keyCode)
        }
        
        bleService.sendKeyboardReport(report)
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        print("ContentView: Handling mouse event: \(event.type), dx: \(event.deltaX), dy: \(event.deltaY),")
        
        // Clamp delta values to Int8 range (-128 to 127)
        var deltaX = Int8(max(min(event.deltaX, 127), -128))
        var deltaY = Int8(max(min(event.deltaY, 127), -128))

        var scrollDeltaY = Int8(0)
        var scrollDeltaX = Int8(0)

        if event.type == .scrollWheel {
            scrollDeltaY = Int8(max(min(event.deltaX * 10, 127), -128))
            scrollDeltaX = Int8(max(min(event.deltaY * 10, 127), -128))
            deltaX = Int8(0)
            deltaY = Int8(0)
        }

        var report: [UInt8] = [0, 0, 0, 0, 0]
        
        report[0] = UInt8(NSEvent.pressedMouseButtons)
        report[1] = UInt8(bitPattern: deltaX)
        report[2] = UInt8(bitPattern: deltaY)
        report[3] = UInt8(bitPattern: scrollDeltaY)
        report[4] = UInt8(bitPattern: scrollDeltaX)
        bleService.sendMouseReport(report)
    }
} 