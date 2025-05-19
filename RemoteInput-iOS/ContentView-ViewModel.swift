import SwiftUI
import CoreGraphics
import OSLog


extension ContentView {
    @Observable
    class ViewModel {
        var bleService: BLEService
        var reportController: ReportController
        
        init() {
            Logger.contentViewViewModel.trace("Initializing view model")
            let bleService = BLEService()
            self.bleService = bleService
            self.reportController = ReportController(bleService: bleService)
        }
        
        func handleNewDeviceDiscovery() {
            guard bleService.connectionState == .disconnected else { return }
            
            // Connect to the first discovered device
            if let firstDevice = bleService.discoveredDevices.first {
                Logger.contentViewViewModel.trace("Auto-connecting to discovered device: \(firstDevice.name ?? "Unknown")")
                bleService.connect(to: firstDevice)
                bleService.stopScanning()
            }
        }
    }
}
