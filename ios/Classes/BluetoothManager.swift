
import CoreBluetooth

class BluetoothManager: NSObject {
    var isAvailable: Bool {
        centralManager?.state != .unsupported && centralManager?.state != .unknown
    }
    var isOn: Bool {
        centralManager?.state == .poweredOn
    }
    var mangerStateInt: Int {
        centralManager.map { self.convertToStateNumber(from: $0.state) } ?? -1
    }
    var isDiscovering: Bool {
        centralManager?.isScanning ?? false
    }

    private let stateEventChannelStreamHandler: StateEventChannelStreamHandler
    private let discveryEventChannelStreamHandler: DiscoveryEventChannelStreamHandler

    private var centralManager: CBCentralManager?
    private var scannedPeripherals: [(peripheral: CBPeripheral, rssi: Int)] = []

    init(stateEventChannelStreamHandler: StateEventChannelStreamHandler,
         discveryEventChannelStreamHandler: DiscoveryEventChannelStreamHandler) {
        self.stateEventChannelStreamHandler = stateEventChannelStreamHandler
        self.discveryEventChannelStreamHandler = discveryEventChannelStreamHandler

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startDiscovery() {
        centralManager?.scanForPeripherals(withServices: nil)
    }

    func cancelDiscovery() {
        centralManager?.stopScan()
    }

    func bondedDevice() -> [[String: Any]] {
        scannedPeripherals.filter { $0.peripheral.state == .connected }.map { self.convertToDictionary(from: $0.peripheral, rssi: $0.rssi) }
    }

    func deviceBondState(at identifier: String) -> Int {
        scannedPeripherals
            .first { $0.peripheral.identifier.uuidString == identifier }
            .map { self.convertToConnectedNumber(from: $0.peripheral.state) } ?? 0
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("new state: \(central.state)")
        stateEventChannelStreamHandler.sink(stateInteger: convertToStateNumber(from: central.state))
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        scannedPeripherals.append((peripheral: peripheral, rssi: RSSI.intValue))
        discveryEventChannelStreamHandler.sink(argument: convertToDictionary(from: peripheral, rssi: RSSI.intValue))
    }
}

private extension BluetoothManager {
    // Match status codes with Android as much as possible
    func convertToStateNumber(from state: CBManagerState) -> Int {
        switch state {
        case .unknown:
            return state.rawValue
        case .unsupported, .unauthorized, .resetting:
            return 0
        case .poweredOff:
            return 10
        case .poweredOn:
            return 12
        }
    }

    func convertToDictionary(from peripheral: CBPeripheral, rssi: Int) -> [String: Any] {
        let name = peripheral.name ?? ""
        let address = peripheral.identifier.uuidString
        let type = 0
        let isConnected = false // TODO: It need calculate
        let bondState = convertToConnectedNumber(from: peripheral.state)

        return [
            "name": name,
            "address": address,
            "type": type,
            "isConnected": isConnected,
            "bondState": bondState,
            "rssi": rssi
        ]
    }

    // Match status codes with Android as much as possible
    func convertToConnectedNumber(from state: CBPeripheralState) -> Int {
        switch state {
        case .disconnected, .disconnecting:
            return 10
        case .connecting:
            return 11
        case .connected:
            return 12
        }
    }
}
