import SwiftUI
import CoreGraphics
import OSLog
import AppKit
import CoreBluetooth

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            NavigationSplitView() {
                sidebarContent
            } detail: {
                mainContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "contentView")
        .onAppear {
            Logger.contentView.trace("View appeared, setting up event monitoring")
            viewModel.setupEventMonitoring()
        }
        .onChange(of: viewModel.bleService.isPoweredOn) { oldValue, newValue in
            if newValue {
                Logger.contentView.trace("Bluetooth powered on, starting scanning")
                viewModel.bleService.startScanning()
            }
        }
        .onChange(of: viewModel.bleService.connectionState) { oldValue, newValue in
            switch newValue {
            case .connecting:
                viewModel.bleService.stopScanning()
            case .connected, .ready:
                viewModel.bleService.stopScanning()
            case .disconnected:
                viewModel.isMouseTrapped = false
                break
            case .pairing:
                // Keep scanning while pairing is in progress
                break
            }
        }
        .onChange(of: viewModel.isMouseTrapped) { oldValue, newValue in
            if newValue {
                NSCursor.hide()
            } else {
                NSCursor.unhide()
            }
        }
    }
    
    private var sidebarContent: some View {
        List {
            Section(header: Text("Device")) {
                if !viewModel.bleService.isPoweredOn {
                    Text("Bluetooth is off")
                        .foregroundColor(.secondary)
                } else if viewModel.bleService.connectionState == .ready, let connectedDevice = viewModel.bleService.devicePeripheral {
                    DeviceRow(device: connectedDevice,
                            isConnected: true,
                            onConnect: { viewModel.connectToDevice(connectedDevice) },
                            onDisconnect: { viewModel.disconnectFromDevice() })
                } else {
                    Text("No device connected")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Special Functions")) {
                Button(action: viewModel.reportController.pasteFromClipboard) {
                    Label("Paste from Clipboard", systemImage: "clipboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.bleService.connectionState != .ready)

                Button(action: viewModel.reportController.sendCtrlAltDel) {
                    Label("Send Ctrl+Alt+Del", systemImage: "keyboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.bleService.connectionState != .ready)
                
                Button(action: viewModel.reportController.sendCtrlAltT) {
                    Label("Send ^⌥T (Ctrl+Alt+T)", systemImage: "keyboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.bleService.connectionState != .ready)
                
                Button(action: viewModel.reportController.sendMetaTab) {
                    Label("Send ⌘⇥ (Meta+Tab)", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.bleService.connectionState != .ready)
            }
            
            if viewModel.reportController.queueSize >= 10 {
                queueStatusView
            }
        }
        .navigationSplitViewColumnWidth(200)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var queueStatusView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Queue: \(viewModel.reportController.queueSize) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { viewModel.reportController.clearQueue() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal, 5)
    }
    
    private var mainContent: some View {
        Group {
            if viewModel.bleService.connectionState == .ready {
                // Mouse input area when connected
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        VStack(spacing: 16) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 40))
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(viewModel.isKeyboardForwardingEnabled || viewModel.isMouseTrapped ? Color.green : Color.yellow)
                                    .frame(width: 8, height: 8)
                                
                                Text(viewModel.isKeyboardForwardingEnabled || viewModel.isMouseTrapped ? 
                                    "Keyboard input forwarding is active" : 
                                    "Keyboard input forwarding is paused")
                                    .foregroundColor(.primary)
                            }
                            .font(.headline)
                                
                            if (!viewModel.isMouseTrapped) {
                                Text("Use toggle below to enable forwarding of keyboard input to the remote device.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)

                                Toggle(isOn: $viewModel.isKeyboardForwardingEnabled) {
                                    Text("Keyboard Forwarding")
                                }
                                .toggleStyle(.switch)                                
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()

                    VStack(spacing: 10) {
                        VStack(spacing: 16) {
                            Image(systemName: "cursorarrow.motionlines")
                                .font(.system(size: 40))
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(viewModel.isMouseTrapped ? Color.green : Color.yellow)
                                    .frame(width: 8, height: 8)
                                
                                Text(viewModel.isMouseTrapped ? "Mouse input forwarding is active" : "Mouse input forwarding is paused")
                                    .foregroundColor(.primary)
                            }
                            .font(.headline)
                                                            
                            if viewModel.isMouseTrapped {
                                Text("Mouse is trapped in this area. Press ⌃⌥T (Control + Option + T) to exit forwarding mode.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Click the button below to start forwarding of both - mouse and keyboard input to the remote device.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    viewModel.isMouseTrapped = true
                                }) {
                                    Text("Start Forwarding")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                                .padding(.top, 8)
                                
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frameReader(frame: $viewModel.mainContentViewFrame, coordinateSpace: .named("contentView"))
            } else {
                // Device scanning and connection interface when not connected
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        if !viewModel.bleService.isPoweredOn {
                            VStack(spacing: 16) {
                                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                    .font(.system(size: 40))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.red)
                                Text("Bluetooth is turned off")
                                    .font(.headline)
                                Text("Please turn on Bluetooth in System Settings to connect to the Remote Input Dongle")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.BluetoothSettings")!)
                                }) {
                                    Text("Open Bluetooth Settings")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else if viewModel.bleService.isScanning {
                            VStack(spacing: 16) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 40))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                    .rotationEffect(.degrees(viewModel.bleService.isScanning ? 360 : 0))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: viewModel.bleService.isScanning)
                                Text("Searching for devices...")
                                    .font(.headline)
                                Text("Make sure your Remote Input Dongle is powered on and in range")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    viewModel.bleService.stopScanning()
                                }) {
                                    Text("Stop Scanning")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else if [.connecting, .connected].contains(viewModel.bleService.connectionState) {
                            VStack(spacing: 16) {
                                Image(systemName: "link.circle")
                                    .font(.system(size: 40))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.orange)
                                Text("Connecting to device...")
                                    .font(.headline)
                                Text("Please wait while we establish the connection")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else if viewModel.bleService.connectionState == .pairing {
                            VStack(spacing: 16) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 40))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.orange)
                                Text("Establishing secure connection...")
                                    .font(.headline)
                                Text("Please accept the pairing request on your device")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 40))
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                                Text("Ready to connect")
                                    .font(.headline)
                                Text("Click 'Start Scanning' to find your Remote Input Dongle")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    viewModel.bleService.startScanning()
                                }) {
                                    Text("Start Scanning")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    if !viewModel.bleService.discoveredDevices.isEmpty && 
                       ![.connecting, .connected, .pairing, .ready].contains(viewModel.bleService.connectionState) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Available Devices")
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.bleService.discoveredDevices.count) found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.bleService.discoveredDevices, id: \.identifier) { device in
                                        Button(action: { viewModel.connectToDevice(device) }) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(device.name ?? "Unknown Device")
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 20))
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                        .contentShape(Rectangle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical)
                            }
                            .frame(maxHeight: 300)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
}

struct DeviceRow: View {
    let device: CBPeripheral
    let isConnected: Bool
    let onConnect: () -> Void
    let onDisconnect: () -> Void
    
    var body: some View {
        HStack {
            Text(device.name ?? "Unknown Device")
                .font(.headline)
            
            Spacer()
            
            if isConnected {
                Button(action: onDisconnect) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            } else {
                Button(action: onConnect) {
                    Image(systemName: "link.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
