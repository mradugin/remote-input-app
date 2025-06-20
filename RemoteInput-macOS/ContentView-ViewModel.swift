import SwiftUI
import CoreGraphics
import OSLog
import CoreBluetooth
import AppKit
import Carbon.HIToolbox.Events

extension ContentView {
    @Observable
    class ViewModel {
        var bleService: BLEService
        var reportController: ReportController
        
        var isMouseTrapped = false
        var mainContentViewFrame: CGRect = .zero
        
        var isKeyboardForwardingEnabled = false
        
        init() {
            Logger.contentViewViewModel.trace("Initializing view model")
            let bleService = BLEService()
            self.bleService = bleService
            self.reportController = ReportController(bleService: bleService)
        }
        
        func connectToDevice(_ device: CBPeripheral) {
            Logger.contentViewViewModel.trace("Connecting to device: \(device.name ?? "Unknown")")
            bleService.connect(to: device)
        }
        
        func disconnectFromDevice() {
            Logger.contentViewViewModel.trace("Disconnecting from device")
            bleService.disconnect()
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
        
        func setupEventMonitoring() {
            Logger.contentViewViewModel.trace("Setting up event monitoring")
            
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                return self?.handleModifierEvent(event)
            }
            
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
                return self?.handleKeyboardEvent(event)
            }
            
            NSEvent.addLocalMonitorForEvents(matching: [
                .mouseMoved,
                .leftMouseDown, .leftMouseUp,
                .rightMouseDown, .rightMouseUp,
                .leftMouseDragged, .rightMouseDragged,
                .scrollWheel]) { [weak self] event in
                    self?.handleMouseEvent(event)
                    return event
                }
        }
        
        private func handleModifierEvent(_ event: NSEvent) -> NSEvent? {
            Logger.events.trace("Handling modifier event: \(event.type.rawValue, privacy: .private), modifierFlags: \(event.modifierFlags.rawValue, privacy: .private)")
            if isKeyboardForwardingEnabled || isMouseTrapped {
                reportController.reportKeyboardEvent(event.modifierFlags, true, nil)
                return nil
            }
            return event
        }
        
        private func handleKeyboardEvent(_ event: NSEvent) -> NSEvent? {
            Logger.events.trace("Handling keyboard event: \(event.type.rawValue, privacy: .private), keycode: \(event.keyCode, privacy: .private), modifierFlags: \(event.modifierFlags.rawValue, privacy: .private)")

            // Check for Control+Option+T to toggle mouse trapping
            if event.type == .keyDown && 
            event.keyCode == kVK_ANSI_T && // 't' key
            event.modifierFlags.contains(.control) && 
            event.modifierFlags.contains(.option) {
                isMouseTrapped.toggle()
                return nil
            }

            if isKeyboardForwardingEnabled || isMouseTrapped {

                // Ignore Command+Tab events
                if event.keyCode == kVK_Tab && // Tab key
                event.modifierFlags.contains(.command) {
                    return nil
                }

                reportController.reportKeyboardEvent(event.modifierFlags, event.type == .keyDown, Int(event.keyCode))
                return nil
            }
            return event
        }

        private func handleMouseEvent(_ event: NSEvent) {
            Logger.events.trace("Handling mouse event: \(event.type.rawValue, privacy: .private), buttons: \(NSEvent.pressedMouseButtons, privacy: .private), dx: \(event.deltaX, privacy: .private), dy: \(event.deltaY, privacy: .private)")
            if isMouseTrapped {
                // Check if mouse is within the main content area
                guard let window = NSApp.windows.first(where: { $0.isKeyWindow }) else {
                    return
                }

                let frame = CGRect(x: mainContentViewFrame.origin.x, y: 0,
                    width: mainContentViewFrame.width, height: mainContentViewFrame.height)
                    .insetBy(dx: 4, dy: 4) // Decrease area as above size calculations are not exact

                let originY = NSScreen.screens[0].frame.maxY - window.frame.maxY
                var mainContentCenterInScreenCoords = window.convertPoint(toScreen: NSPoint(x: frame.midX, y: 0))
                mainContentCenterInScreenCoords.y = originY + mainContentViewFrame.midY
                
                reportController.reportMouseEvent(event)

                CGWarpMouseCursorPosition(mainContentCenterInScreenCoords)
            }
            return
        }
    }
}
