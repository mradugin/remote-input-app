import SwiftUI
import CoreGraphics
import OSLog
#if os(iOS)
import UIKit
#else
import AppKit
import Carbon.HIToolbox.Events
#endif

extension ContentView {
    @Observable
    class ViewModel {
        var bleService: BLEService
        var reportController: ReportController
        
        var ignoreNextMouseMove = false
        var isMouseTrapped = false
        var mainContentViewFrame: CGRect = .zero
        
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
        
        func setupEventMonitoring() {
            Logger.contentViewViewModel.trace("Setting up event monitoring")
            
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
            Logger.contentViewViewModel.trace("Handling modifier event: \(event.type.rawValue), modifierFlags: \(event.modifierFlags.rawValue)")
            reportController.reportKeyboardEvent(event.modifierFlags, true, nil)
        }
        
        private func handleKeyboardEvent(_ event: NSEvent) {
            Logger.contentViewViewModel.trace("Handling keyboard event: \(event.type.rawValue), keycode: \(event.keyCode), modifierFlags: \(event.modifierFlags.rawValue)")

            // Check for Control+Option+T to toggle mouse trapping
            if event.type == .keyDown && 
            event.keyCode == kVK_ANSI_T && // 't' key
            event.modifierFlags.contains(.control) && 
            event.modifierFlags.contains(.option) {
                isMouseTrapped.toggle()
                return
            }

            // Ignore Command+Tab events
            if event.keyCode == kVK_Tab && // Tab key
               event.modifierFlags.contains(.command) {
                return
            }

            reportController.reportKeyboardEvent(event.modifierFlags, event.type == .keyDown, Int(event.keyCode))
        }

        func moveMouse(to point: CGPoint) {
            Logger.contentViewViewModel.trace("Moving mouse to: \(point.x), \(point.y)")
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

            Logger.contentViewViewModel.trace("Handling mouse event: \(event.type.rawValue), buttons: \(NSEvent.pressedMouseButtons), dx: \(event.deltaX), dy: \(event.deltaY), abs mouseLocation: \(NSEvent.mouseLocation.x), \(NSEvent.mouseLocation.y)")
            
            let locationInWindow = event.locationInWindow
            let frame = CGRect(x: mainContentViewFrame.origin.x, y: 0, 
                width: mainContentViewFrame.width, height: mainContentViewFrame.height)
                .insetBy(dx: 4, dy: 4) // Decrease area as above size calculations are not exact
            guard frame.contains(locationInWindow) else {
                Logger.contentViewViewModel.trace("Mouse is outside main content area")
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
    }
}
