import SwiftUI
import AppKit
import CoreGraphics

struct ContentView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            mainContent
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
        .onChange(of: viewModel.bleService.connectionState) { oldValue, newValue in
            if newValue == .connecting {
                viewModel.bleService.stopScanning()
            }
            else if newValue == .disconnected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("ContentView: Disconnected, starting automatic scanning")
                    viewModel.bleService.startScanning()
                }
            }
        }
    }
    
    private var sidebarContent: some View {
        List {
            Text("Special Functions")
                .font(.headline)
            Button(action: viewModel.sendCtrlAltDel) {
                Label("Ctrl+Alt+Del", systemImage: "keyboard")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.bleService.connectionState != .ready)
            
            Button(action: viewModel.pasteFromClipboard) {
                Label("Paste", systemImage: "clipboard")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.bleService.connectionState != .ready)

            Divider()
            
            Toggle(isOn: $viewModel.isMouseTrapped) {
                Label("Trap Mouse", systemImage: "cursorarrow.square")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toggleStyle(.switch)
            .disabled(viewModel.bleService.connectionState != .ready)
            
            Toggle(isOn: $viewModel.isCursorHidden) {
                Label("Hide Cursor", systemImage: "cursorarrow.slash")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .toggleStyle(.switch)
            .disabled(viewModel.bleService.connectionState != .ready)
            
            Divider()
            
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
        VStack {
            Spacer()
            
            VStack(spacing: 5) {
                Text("Remote Input Area")
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
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(FrameReader(frame: $viewModel.mainContentViewFrame, coordinateSpace: .named("contentView")))
        .border(viewModel.bleService.connectionState == .ready ? Color.green : Color.clear, width: 2)
        .onHover { isHovering in
            if isHovering && viewModel.isCursorHidden {
                NSCursor.hide()
            } else {
                NSCursor.unhide()
            }
        }
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
