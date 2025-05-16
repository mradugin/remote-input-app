import SwiftUI
import AppKit
import CoreGraphics

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        print("ContentView: Building view body")
        return NavigationSplitView() {
            // Sidebar
            List {
                Text("Special Functions")
                    .font(.headline)
                Button(action: viewModel.sendCtrlAltDel) {
                    Label("Ctrl+Alt+Del", systemImage: "keyboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.bleService.isConnected)
                
                Button(action: viewModel.pasteFromClipboard) {
                    Label("Paste", systemImage: "clipboard")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.bleService.isConnected)

                Divider()
                
                Toggle(isOn: $viewModel.isMouseTrapped) {
                    Label("Trap Mouse", systemImage: "cursorarrow.square")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
                .disabled(!viewModel.bleService.isConnected)
                
                Toggle(isOn: $viewModel.isCursorHidden) {
                    Label("Hide Cursor", systemImage: "cursorarrow.slash")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
                .disabled(!viewModel.bleService.isConnected)
                
                Divider()
                
                if viewModel.reportController.queueSize >= 10 {
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
                            if viewModel.bleService.isConnected {
                                Text("Connected")
                                    .foregroundColor(.green)
                            } else if !viewModel.bleService.isPoweredOn {
                                Text("Bluetooth Off")
                                    .foregroundColor(.red)
                            } else if viewModel.bleService.isScanning {
                                Text("Scanning...")
                                    .foregroundColor(.yellow)
                            } else if viewModel.bleService.isConnecting {
                                Text("Connecting...")
                                    .foregroundColor(.orange)
                            } else {
                                Text("Disconnected")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if viewModel.bleService.isConnected {
                            Text("All the keyboard and mouse input within this area is being sent to the remote device")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if viewModel.isMouseTrapped {
                                Text("Mouse is trapped in this area. Press Ctrl+Alt+T to disable trapping.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        } else if !viewModel.bleService.isPoweredOn {
                            Text("Please turn on Bluetooth to connect to the Remote Input Dongle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if viewModel.bleService.isScanning {
                            Text("Searching for Remote Input Dongle...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if viewModel.bleService.isConnecting {
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
            .modifier(FrameReader(frame: $viewModel.mainContentViewFrame, coordinateSpace: .named("contentView")))
            .border(viewModel.bleService.isConnected ? Color.green : Color.clear, width: 2)
            .onHover { isHovering in
                if isHovering && viewModel.isCursorHidden {
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
            viewModel.setupEventMonitoring()
        }
        .onChange(of: viewModel.bleService.isPoweredOn) { oldValue, newValue in
            if newValue {
                print("ContentView: Bluetooth powered on, starting automatic scanning")
                viewModel.bleService.startScanning()
            }
        }
        .onChange(of: viewModel.bleService.discoveredDevices) { oldValue, newValue in
            viewModel.handleNewDeviceDiscovery()
        }
        .onChange(of: viewModel.bleService.isConnected) { oldValue, newValue in
            if newValue {
                viewModel.bleService.stopScanning()
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("ContentView: Disconnected, starting automatic scanning")
                    viewModel.bleService.startScanning()
                }
            }
        }
    }
}
