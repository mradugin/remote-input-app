import SwiftUI
import AppKit
import CoreGraphics

extension NSWindow {
    var titlebarHeight: CGFloat {
        frame.height - contentLayoutRect.height
    }
}

struct FrameReader: ViewModifier {
    @Binding var frame: CGRect
    let coordinateSpace: CoordinateSpace
    
    func body(content: Content) -> some View {
        content
        .background {
            GeometryReader { geometryValue in
                let frame = geometryValue.frame(in: coordinateSpace)
                Color.clear
                .onAppear {
                    self.frame = frame
                }
                .onChange(of: frame) { newValue in
                    self.frame = newValue
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var bleService = BLEService()
    @StateObject private var reportController: ReportController

    @State private var ignoreNextMouseMove = false
    @State private var isMouseTrapped = false
    @State private var isCursorHidden = false
    @State private var mainContentViewFrame: CGRect = .zero
    
    init() {
        print("ContentView: Initializing view")
        let bleService = BLEService()
        _bleService = StateObject(wrappedValue: bleService)
        _reportController = StateObject(wrappedValue: ReportController(bleService: bleService))
    }
    
    var body: some View {
        print("ContentView: Building view body")
        return NavigationSplitView(columnVisibility: .constant(.all)) {
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

                Divider()
                
                Toggle(isOn: $isMouseTrapped) {
                    Label("Trap Mouse", systemImage: "cursorarrow.square")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
                .disabled(!bleService.isConnected)
                
                Toggle(isOn: $isCursorHidden) {
                    Label("Hide Cursor", systemImage: "cursorarrow.slash")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
                .disabled(!bleService.isConnected)
                
                Divider()
                
                HStack {
                    Text("Queue: \(reportController.queueSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: { reportController.clearQueue() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .disabled(reportController.queueSize < 100)
                }
                .padding(.vertical, 4)
            }
            .navigationSplitViewColumnWidth(200)
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
                            
                            if isMouseTrapped {
                                Text("Mouse is trapped in this area. Press Ctrl+Alt+T to disable trapping.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
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
            .modifier(FrameReader(frame: $mainContentViewFrame, coordinateSpace: .named("contentView")))
            .border(bleService.isConnected ? Color.green : Color.clear, width: 2)
            .onHover { isHovering in
                if isHovering && isCursorHidden {
                    NSCursor.hide()
                } else {
                    NSCursor.unhide()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "contentView")
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
        reportController.reportKeyboardEvent(event.modifierFlags, true, nil)
    }
    
    private func handleKeyboardEvent(_ event: NSEvent) {
        print("ContentView: Handling keyboard event: \(event.type), keycode: \(event.keyCode), " +
            "modifierFlags: \(event.modifierFlags.rawValue)")

        // Check for Ctrl+Alt+T to toggle mouse trapping
        if event.type == .keyDown && 
           event.keyCode == 17 && // 't' key
           event.modifierFlags.contains(.control) && 
           event.modifierFlags.contains(.option) {
            isMouseTrapped.toggle()
            return
        }

        reportController.reportKeyboardEvent(event.modifierFlags, event.type == .keyDown, Int(event.keyCode))
    }

    func moveMouse(to point: CGPoint) {
        print("ContentView: Moving mouse to: \(point)")
        CGWarpMouseCursorPosition(point)
        CGAssociateMouseAndMouseCursorPosition(1)
        ignoreNextMouseMove = true
    }

    private func handleMouseEvent(_ event: NSEvent) {
        if ignoreNextMouseMove {
            ignoreNextMouseMove = false
            return
        }

        // Check if mouse is within the main content area
        guard let window = NSApp.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        print("ContentView: Handling mouse event: \(event.type), buttons: \(NSEvent.pressedMouseButtons), " +
            "dx: \(event.deltaX), dy: \(event.deltaY), abs mouseLocation: \(NSEvent.mouseLocation.x), \(NSEvent.mouseLocation.y)")
        
        let locationInWindow = event.locationInWindow
        let frame = CGRect(x: mainContentViewFrame.origin.x, y: 0, 
            width: mainContentViewFrame.width, height: mainContentViewFrame.height)
            .insetBy(dx: 4, dy: 4) // Decrease area as above size calculations are not exact
        guard frame.contains(locationInWindow) else {
            print("ContentView: Mouse is outside main content area")
            if isMouseTrapped {
                let originY = NSScreen.screens[0].frame.maxY - window.frame.maxY
                var mainContentCenterInScreenCoords = window.convertPoint(toScreen: NSPoint(x: frame.midX, y: 0))
                mainContentCenterInScreenCoords.y = originY + mainContentViewFrame.midY
                moveMouse(to: mainContentCenterInScreenCoords)
            }
            return
        }

        reportController.reportMouseEvent(event)
    }
    
    private func sendCtrlAltDel() {
        reportController.sendCtrlAltDel()
    }
    
    private func pasteFromClipboard() {
        reportController.pasteFromClipboard()
    }
}
