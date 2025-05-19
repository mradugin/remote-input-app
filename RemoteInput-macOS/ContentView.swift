import SwiftUI
import CoreGraphics
import OSLog
import AppKit

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var showSidebar = false
    @State private var showKeyboard = false
    
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
                Logger.contentView.trace("Bluetooth powered on, starting automatic scanning")
                viewModel.bleService.startScanning()
            }
        }
        .onChange(of: viewModel.bleService.discoveredDevices) { oldValue, newValue in
            viewModel.handleNewDeviceDiscovery()
        }
        .onChange(of: viewModel.bleService.connectionState) { oldValue, newValue in
            if newValue == .connecting {
                viewModel.bleService.stopScanning()
            }
            else if newValue == .disconnected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Logger.contentView.trace("Disconnected, starting automatic scanning")
                    viewModel.bleService.startScanning()
                }
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

            Section(header: Text("Mouse Handling")) {
                Toggle(isOn: $viewModel.isMouseTrapped) {
                    Label("Trap Mouse", systemImage: "cursorarrow.square")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .toggleStyle(.switch)
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
        ZStack {
            VStack {
                Text("Mouse Input Area")
                    .font(.title)
                    .padding(.bottom, 10)
                
                VStack(spacing: 10) {
                    HStack {
                        Text("Status:")
                        statusText
                    }
                    
                    if viewModel.bleService.connectionState == .ready {
                        Text("All the keyboard and mouse input within this area is being sent to the remote device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        if viewModel.isMouseTrapped {
                            Text("Mouse is trapped in this area. Press ⌃⌥T (Control + Option + T) to disable trapping.")
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
                    } else if [.connecting, .connected].contains(viewModel.bleService.connectionState) {
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
            .padding()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(FrameReader(frame: $viewModel.mainContentViewFrame, coordinateSpace: .named("contentView")))
        .border(viewModel.bleService.connectionState == .ready ? Color.green : Color.clear, width: 2)
    }
    
    private var statusText: some View {
        Group {
            if viewModel.bleService.connectionState == .ready {
                Text("Ready")
                    .foregroundColor(.green)
            } else if !viewModel.bleService.isPoweredOn {
                Text("Bluetooth Off")
                    .foregroundColor(.red)
            } else if viewModel.bleService.isScanning {
                Text("Scanning...")
                    .foregroundColor(.yellow)
            } else if [.connecting, .connected].contains(viewModel.bleService.connectionState) {
                Text("Connecting...")
                    .foregroundColor(.orange)
            } else {
                Text("Disconnected")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    ContentView()
}
