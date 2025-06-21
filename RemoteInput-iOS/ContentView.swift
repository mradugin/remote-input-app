import SwiftUI
import CoreGraphics
import OSLog

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var selectedInputMode: InputMode = .keyboard
    
    enum InputMode {
        case keyboard
        case touch
    }
    
    var body: some View {
        Group {
            NavigationStack {
                mainContent
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
    
    private var mainContent: some View {
        ZStack {
            if viewModel.bleService.connectionState == .ready {
                VStack {
                    ZStack {
                        KeyboardInputView(reportController: viewModel.reportController, selectedInputMode: $selectedInputMode)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if selectedInputMode == .touch {
                            TouchInputHandlerView(reportController: viewModel.reportController, selectedInputMode: $selectedInputMode)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.7))
                                .overlay(alignment: .bottom) {
                                    Button(action: { selectedInputMode = .keyboard }) {
                                        Label("Keyboard", systemImage: "keyboard")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                    .padding(.bottom, 16)
                                }
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "bluetooth")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Connecting to Remote Input Dongle...")
                        .font(.title2)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Status:")
                            statusText
                        }
                        
                        if !viewModel.bleService.isPoweredOn {
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
                        } else if viewModel.bleService.connectionState == .pairing {
                            Text("Establishing secure connection...")
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            } else if viewModel.bleService.connectionState == .pairing {
                Text("Pairing...")
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
