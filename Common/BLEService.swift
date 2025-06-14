import Foundation
import CoreBluetooth
import OSLog

@Observable
public class BLEService: NSObject {
    private var centralManager: CBCentralManager!
    var devicePeripheral: CBPeripheral?
    private var keyboardCharacteristic: CBCharacteristic?
    private var mouseCharacteristic: CBCharacteristic?
    private var statusCharacteristic: CBCharacteristic?
    
    // Custom UUIDs for the service and characteristics
    let SERVICE_UUID            = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    let KEYBOARD_CHAR_UUID      = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    let MOUSE_CHAR_UUID         = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a9")
    let STATUS_CHAR_UUID        = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26aa")
   
    // Device tracking
    private var deviceLastSeen: [UUID: Date] = [:]
    private let deviceTimeout: TimeInterval = 5.0 // Remove device after 5 seconds of not being seen
    
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case pairing
        case ready
    }
    
    // Published properties for UI updates
    var discoveredDevices: [CBPeripheral] = []
    var isScanning = false
    var isPoweredOn = false
    var connectionState: ConnectionState = .disconnected
    
    override init() {
        super.init()
        Logger.bleService.trace("Initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func removeStaleDevices() {
        let now = Date()
        discoveredDevices.removeAll { device in
            if let lastSeen = deviceLastSeen[device.identifier] {
                return now.timeIntervalSince(lastSeen) > deviceTimeout
            }
            return true
        }
    }
    
    func startScanning() {
        Logger.bleService.trace("Starting scan")
        guard centralManager.state == .poweredOn else {
            Logger.bleService.trace("Bluetooth is not powered on")
            return
        }
        
        discoveredDevices.removeAll()
        deviceLastSeen.removeAll()
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
        isScanning = true
    }
    
    func stopScanning() {
        Logger.bleService.trace("Stopping scan")
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to peripheral: CBPeripheral) {
        Logger.bleService.trace("Connecting to peripheral: \(peripheral.identifier)")
        connectionState = .connecting
        devicePeripheral = peripheral
        centralManager.connect(peripheral)
    }
    
    func disconnect() {
        if let peripheral = devicePeripheral {
            Logger.bleService.trace("Disconnecting from peripheral: \(peripheral.identifier)")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func sendKeyboardReport(_ report: [UInt8]) {
        guard connectionState == .ready, let peripheral = devicePeripheral,
              let characteristic = keyboardCharacteristic else { return }
        
        peripheral.writeValue(Data(report), for: characteristic, type: .withoutResponse)
    }
    
    func sendMouseReport(_ report: [UInt8]) {
        guard connectionState == .ready, let peripheral = devicePeripheral,
              let characteristic = mouseCharacteristic else { return }
        
        peripheral.writeValue(Data(report), for: characteristic, type: .withoutResponse)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Logger.bleService.trace("Central manager state updated: \(central.state.rawValue)")
        isPoweredOn = central.state == .poweredOn
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Logger.bleService.trace("Discovered peripheral: \(peripheral.identifier) with RSSI: \(RSSI)")
        
        // Update last seen time
        deviceLastSeen[peripheral.identifier] = Date()
        
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard devicePeripheral == peripheral else { return }
        Logger.bleService.trace("Connected to peripheral: \(peripheral.identifier)")
        connectionState = .connected
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard devicePeripheral == peripheral else { return }
        Logger.bleService.trace("Disconnected from peripheral: \(peripheral.identifier)")
        devicePeripheral = nil
        keyboardCharacteristic = nil
        mouseCharacteristic = nil
        statusCharacteristic = nil
        connectionState = .disconnected
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard devicePeripheral == peripheral else { return }
        Logger.bleService.trace("Failed to connect to peripheral: \(peripheral.identifier)")
        if let error = error {
            Logger.bleService.trace("Error: \(error.localizedDescription)")
        }
        devicePeripheral = nil
        connectionState = .disconnected
    }
}

// MARK: - CBPeripheralDelegate
extension BLEService: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            Logger.bleService.trace("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let service = peripheral.services?.first else { return }
        Logger.bleService.trace("Discovered service: \(service.uuid)")
        connectionState = .pairing
        peripheral.discoverCharacteristics([KEYBOARD_CHAR_UUID, MOUSE_CHAR_UUID, STATUS_CHAR_UUID], for: service)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            Logger.bleService.trace("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        for characteristic in service.characteristics ?? [] {
            Logger.bleService.trace("Discovered characteristic: \(characteristic.uuid)")
            if characteristic.uuid == KEYBOARD_CHAR_UUID {
                keyboardCharacteristic = characteristic
            } else if characteristic.uuid == MOUSE_CHAR_UUID {
                mouseCharacteristic = characteristic
            } else if characteristic.uuid == STATUS_CHAR_UUID {
                statusCharacteristic = characteristic
             }
        }

        if (statusCharacteristic != nil) {
            // Try to read the status characteristic to check secure pairing
            peripheral.readValue(for: statusCharacteristic!)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == STATUS_CHAR_UUID {
            if error == nil {
                // If we can read the status characteristic without error, secure pairing is complete
                if keyboardCharacteristic != nil && mouseCharacteristic != nil {
                    connectionState = .ready
                }
            } else {
                // Log error when reading status characteristic
                Logger.bleService.trace("Error reading status characteristic: \(error?.localizedDescription ?? "unknown error")")
                // Abort connection and return to scanning
                disconnect()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == STATUS_CHAR_UUID {
            if error == nil {
                // If we can enable notifications without error, secure pairing is complete
                if keyboardCharacteristic != nil && mouseCharacteristic != nil {
                    connectionState = .ready
                }
            } else {
                // Any error means we're still in pairing
                connectionState = .pairing
            }
        }
    }
}
