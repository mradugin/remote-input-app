import SwiftUI
import CoreGraphics
import OSLog

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var showSidebar = false
    @State private var showKeyboard = false
    
    var body: some View {
        Group {
            NavigationStack {
                mainContent
                    .navigationTitle("Remote Input")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                showSidebar.toggle()
                            } label: {
                                Image(systemName: "sidebar.left")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showKeyboard.toggle()
                            } label: {
                                Image(systemName: "keyboard")
                            }
                        }
                    }
                    .sheet(isPresented: $showSidebar) {
                        NavigationStack {
                            sidebarContent
                        }
                    }
                    .sheet(isPresented: $showKeyboard) {
                        NavigationStack {
                            KeyboardInputView(reportController: viewModel.reportController)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Logger.contentView.trace("View appeared, setting up event monitoring")
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

            if viewModel.reportController.queueSize >= 10 {
                queueStatusView
            }
        }
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

struct TouchInputHandlerView: UIViewControllerRepresentable {
    let reportController: ReportController
    
    func makeUIViewController(context: Context) -> TouchInputHandler {
        TouchInputHandler(reportController: reportController)
    }
    
    func updateUIViewController(_ uiViewController: TouchInputHandler, context: Context) {
    }
}

#Preview {
    ContentView()
}
