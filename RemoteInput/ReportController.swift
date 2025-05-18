import Foundation
import CoreBluetooth
import Combine
import OSLog
#if os(iOS)
import UIKit
#else
import AppKit
#endif

@Observable
class ReportController {
    private let bleService: BLEService
    private var reportQueue: [Report] = []
    private var isProcessingQueue = false
    private let queueProcessingInterval: TimeInterval = 0.005 // 5ms between reports
    private let maxKeysPerReport = 6
    
    private(set) var queueSize: Int = 0
    
    enum Report {
        case keyboard([UInt8])
        case mouse([UInt8])
    }
    
    init(bleService: BLEService) {
        self.bleService = bleService
        startQueueProcessing()
    }
    
    private func startQueueProcessing() {
        Timer.scheduledTimer(withTimeInterval: queueProcessingInterval, repeats: true) { [weak self] _ in
            self?.processNextReport()
        }
    }
    
    private func processNextReport() {
        guard !reportQueue.isEmpty else { return }
        
        let report = reportQueue.removeFirst()
        queueSize = reportQueue.count
        switch report {
        case .keyboard(let data):
            bleService.sendKeyboardReport(data)
        case .mouse(let data):
            bleService.sendMouseReport(data)
        }
    }
    
    func queueReport(_ report: Report) {
        reportQueue.append(report)
        queueSize = reportQueue.count
    }
    
    #if os(macOS)
    func reportKeyboardEvent(_ modifierFlags: NSEvent.ModifierFlags, _ keydown: Bool, _ keyCode: Int?) {
        let modifierMask = KeyMapping.getModifierMask(from: modifierFlags)
        var report: [UInt8] = [modifierMask, 0]
        
        if keydown, let keyCode = keyCode {
            if let usbKeyCode = KeyMapping.getKeyCode(fromEvent: keyCode) {
                report[1] = usbKeyCode
                Logger.reportController.trace("Usb key code: \(usbKeyCode)")
            }
            else {
                Logger.reportController.warning("No usb key code found for keycode: \(keyCode)")
                return
            }
        }
        queueReport(.keyboard(report))
    }
    
    func reportMouseEvent(_ event: NSEvent) {
        if event.type != .scrollWheel {
            let deltaX = Int8(clamp(event.deltaX, min: -128, max: 127))
            let deltaY = Int8(clamp(event.deltaY, min: -128, max: 127))

            let report: [UInt8] = [
                UInt8(NSEvent.pressedMouseButtons),
                UInt8(bitPattern: deltaX),
                UInt8(bitPattern: deltaY)
            ]
            queueReport(.mouse(report))
        }
        else {
            let wheelScroll = Int8(clamp(event.deltaY * 10, min: -128, max: 127))
            let wheelPan = Int8(clamp(event.deltaX * 10, min: -128, max: 127))
            let report: [UInt8] = [
                UInt8(NSEvent.pressedMouseButtons),
                0,
                0,
                UInt8(bitPattern: wheelScroll),
                UInt8(bitPattern: wheelPan)
            ]
            queueReport(.mouse(report))
        }
    }
    #endif
    
    func sendCtrlAltDel() {
        // Send Ctrl+Alt+Del combination
        let report: [UInt8] = [
            UInt8(HIDModifierFlags.LeftCtrl | HIDModifierFlags.LeftAlt),
            HIDKeyCodes.Delete
        ]
        queueReport(.keyboard(report))
        releaseAllKeys()
    }

    func sendCtrlAltT() {
        // Send Ctrl+Alt+T combination
        let report: [UInt8] = [
            UInt8(HIDModifierFlags.LeftCtrl | HIDModifierFlags.LeftAlt),
            HIDKeyCodes.T
        ]
        queueReport(.keyboard(report))
        releaseAllKeys()
    }

    func sendMetaTab() {
        // Send Meta+Tab combination (internally maps to Command+Tab on Mac)
        let report: [UInt8] = [
            UInt8(HIDModifierFlags.LeftMeta),
            HIDKeyCodes.Tab
        ]
        queueReport(.keyboard(report))
        releaseAllKeys()
    }

    func releaseAllKeys() {
        let releaseReport: [UInt8] = [0, 0]
        queueReport(.keyboard(releaseReport))
    }
    
    func pasteFromClipboard() {
        #if os(iOS)
        guard let string = UIPasteboard.general.string else { return }
        #else
        guard let string = NSPasteboard.general.string(forType: .string) else { return }
        #endif
        
        var batch: [UInt8] = []
        var modifier: UInt8 = 0
        // aabbccdd
        for char in string {
            if let asciiValue = char.asciiValue,
               let mapping = KeyMapping.getKeyCode(formAscii: asciiValue) {
                
                // Start new batch if modifier changes or batch is full
                if batch.contains(mapping.keyCode) || 
                    mapping.modifier != modifier || 
                    batch.count >= maxKeysPerReport {
                    if !batch.isEmpty {
                        queueReport(.keyboard([modifier] + batch))
                        releaseAllKeys()
                        batch = []
                    }
                    modifier = mapping.modifier
                }
                
                batch.append(mapping.keyCode)
            }
        }
        
        // Send final batch if any
        if !batch.isEmpty {
            batch.insert(modifier, at: 0)
            queueReport(.keyboard([modifier] + batch))
            releaseAllKeys()
        }
    }
    
    func clearQueue() {
        reportQueue.removeAll()
        releaseAllKeys()
        queueSize = 0
    }
    
    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }
} 
