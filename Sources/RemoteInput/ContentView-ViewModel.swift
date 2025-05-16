import SwiftUI
import AppKit
import CoreGraphics

extension ContentView {
    @Observable
    class ViewModel {
        var bleService: BLEService
        var reportController: ReportController
        
        var ignoreNextMouseMove = false
        var isMouseTrapped = false
        var isCursorHidden = false
        var mainContentViewFrame: CGRect = .zero
        
        init() {
            print("ContentView::ViewModel: Initializing view model")
            let bleService = BLEService()
            self.bleService = bleService
            self.reportController = ReportController(bleService: bleService)
        }
        
        func handleNewDeviceDiscovery() {
            guard !bleService.isConnected else { return }
            
            // Connect to the first discovered device
            if let firstDevice = bleService.discoveredDevices.first {
                print("ContentView::ViewModel: Auto-connecting to discovered device: \(firstDevice.name ?? "Unknown")")
                bleService.connect(to: firstDevice)
                bleService.stopScanning()
            }
        }
        
        func setupEventMonitoring() {
            print("ContentView::ViewModel: Setting up event monitoring")

            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
                self?.handleModifierEvent(event)
                return event
            }

            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
                self?.handleKeyboardEvent(event)
                return nil  // Return nil to prevent system bell sound
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
        
        private func handleModifierEvent(_ event: NSEvent) {
            print("ContentView::ViewModel: Handling modifier event: \(event.type), modifierFlags: \(event.modifierFlags.rawValue)")
            reportController.reportKeyboardEvent(event.modifierFlags, true, nil)
        }
        
        private func handleKeyboardEvent(_ event: NSEvent) {
            print("ContentView::ViewModel: Handling keyboard event: \(event.type), keycode: \(event.keyCode), " +
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
            print("ContentView::ViewModel: Moving mouse to: \(point)")
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

            print("ContentView::ViewModel: Handling mouse event: \(event.type), buttons: \(NSEvent.pressedMouseButtons), " +
                "dx: \(event.deltaX), dy: \(event.deltaY), abs mouseLocation: \(NSEvent.mouseLocation.x), \(NSEvent.mouseLocation.y)")
            
            let locationInWindow = event.locationInWindow
            let frame = CGRect(x: mainContentViewFrame.origin.x, y: 0, 
                width: mainContentViewFrame.width, height: mainContentViewFrame.height)
                .insetBy(dx: 4, dy: 4) // Decrease area as above size calculations are not exact
            guard frame.contains(locationInWindow) else {
                print("ContentView::ViewModel: Mouse is outside main content area")
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
        
        func sendCtrlAltDel() {
            reportController.sendCtrlAltDel()
        }
        
        func pasteFromClipboard() {
            reportController.pasteFromClipboard()
        }
    }
}