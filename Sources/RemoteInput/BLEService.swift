import Foundation
import CoreBluetooth

class BLEService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    private var keyboardCharacteristic: CBCharacteristic?
    private var mouseCharacteristic: CBCharacteristic?
    
    // Custom UUIDs for the service and characteristics
    let SERVICE_UUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    let KEYBOARD_CHAR_UUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    let MOUSE_CHAR_UUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a9")
    
    // Device tracking
    private var deviceLastSeen: [UUID: Date] = [:]
    private let deviceTimeout: TimeInterval = 5.0 // Remove device after 5 seconds of not being seen
    
    // Published properties for UI updates
    @Published var isScanning = false
    @Published var isPoweredOn = false
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var isConnecting = false
    
    override init() {
        super.init()
        print("BLEService: Initializing")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Start timer to check for stale devices
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.removeStaleDevices()
        }
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
        print("BLEService: Starting scan")
        guard centralManager.state == .poweredOn else {
            print("BLEService: Bluetooth is not powered on")
            return
        }
        
        discoveredDevices.removeAll()
        deviceLastSeen.removeAll()
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
        isScanning = true
    }
    
    func stopScanning() {
        print("BLEService: Stopping scan")
        centralManager.stopScan()
        isScanning = false
    }
    
    func connect(to peripheral: CBPeripheral) {
        print("BLEService: Connecting to peripheral: \(peripheral.identifier)")
        isConnecting = true
        centralManager.connect(peripheral)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            print("BLEService: Disconnecting from peripheral: \(peripheral.identifier)")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func sendKeyboardReport(_ report: [UInt8]) {
        guard let peripheral = connectedPeripheral,
              let characteristic = keyboardCharacteristic else { return }
        
        peripheral.writeValue(Data(report), for: characteristic, type: .withoutResponse)
    }
    
    func sendMouseReport(_ report: [UInt8]) {
        guard let peripheral = connectedPeripheral,
              let characteristic = mouseCharacteristic else { return }
        
        peripheral.writeValue(Data(report), for: characteristic, type: .withoutResponse)
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLEService: Central manager state updated: \(central.state)")
        isPoweredOn = central.state == .poweredOn
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("BLEService: Discovered peripheral: \(peripheral.identifier) with RSSI: \(RSSI)")
        
        // Update last seen time
        deviceLastSeen[peripheral.identifier] = Date()
        
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("BLEService: Connected to peripheral: \(peripheral.identifier)")
        connectedPeripheral = peripheral
        isConnecting = false
        isConnected = true
        peripheral.delegate = self

        peripheral.discoverServices([SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("BLEService: Disconnected from peripheral: \(peripheral.identifier)")
        connectedPeripheral = nil
        keyboardCharacteristic = nil
        mouseCharacteristic = nil
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("BLEService: Failed to connect to peripheral: \(peripheral.identifier)")
        if let error = error {
            print("BLEService: Error: \(error.localizedDescription)")
        }
        isConnecting = false
    }
}

// MARK: - CBPeripheralDelegate
extension BLEService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        print("BLEService: Discovered service: \(service.uuid)")
        peripheral.discoverCharacteristics([KEYBOARD_CHAR_UUID, MOUSE_CHAR_UUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            print("BLEService: Discovered characteristic: \(characteristic.uuid)")
            if characteristic.uuid == KEYBOARD_CHAR_UUID {
                keyboardCharacteristic = characteristic
            } else if characteristic.uuid == MOUSE_CHAR_UUID {
                mouseCharacteristic = characteristic
            }
        }
    }
}
