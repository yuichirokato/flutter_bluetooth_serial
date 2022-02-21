import Flutter
import UIKit
import CoreBluetooth

extension CBUUID {
    var fullUUIDString: String {
        uuidString.count == 4
            ? String(format: "0000%@-0000-1000-8000-00805F9B34FB", uuidString)
            : uuidString.lowercased()
    }
}

enum FlutterMethodName: String {
    case isAvailable
    case isOn
    case isEnabled
    case openSettings
    case requestEnable
    case requestDisable
    case ensurePermissions
    case getState
    case getAddress
    case getName
    case setName
    case getDeviceBondState
    case removeDeviceBond
    case bondDevice
    case pairingRequestHandlingEnable
    case pairingRequestHandlingDisable
    case getBondedDevices
    case isDiscovering
    case startDiscovery
    case cancelDiscovery
    case isDiscoverable
    case requestDiscoverable
    case connect
    case write
}

private let stateEventChannelStreamHandler = StateEventChannelStreamHandler()
private let discveryEventChannelStreamHandler = DiscoveryEventChannelStreamHandler()

public class SwiftFlutterBluetoothSerialPlugin: NSObject, FlutterPlugin {
    private var bluetoothManager: BluetoothManager?
    private var isInitialized = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(name: "flutter_bluetooth_serial/methods", binaryMessenger: messenger)
        let instance = SwiftFlutterBluetoothSerialPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let stateChannel = FlutterEventChannel(name: "flutter_bluetooth_serial/state", binaryMessenger: messenger)
        stateChannel.setStreamHandler(stateEventChannelStreamHandler)

        let discoveryChannel = FlutterEventChannel(name: "flutter_bluetooth_serial/discovery", binaryMessenger: messenger)
        discoveryChannel.setStreamHandler(discveryEventChannelStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("FlutterBluetoothSerial: handle called: ", call.method)
        if bluetoothManager == nil {
            bluetoothManager = BluetoothManager()
        }

        guard let method = FlutterMethodName(rawValue: call.method) else {
            result("unknown method '\(call.method)' called.")
            return
        }

        switch method {
        case .isAvailable:
            result(bluetoothManager?.isAvailable ?? false)

        case .isOn, .isEnabled:
            result(bluetoothManager?.isOn ?? false)

        case .openSettings, .requestEnable, .requestDisable:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
                result(true)
            } else {
                result(false)
            }

        case .ensurePermissions:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getState:
            print("\(method.rawValue) called.")
            print("state int: \(bluetoothManager?.mangerStateInt)")
            result(bluetoothManager?.mangerStateInt)

        case .getAddress:
            // It can't get mac address of device in iOS App.
            // So return uuid instead.
            print("\(method.rawValue) called.")
            result(UIDevice.current.identifierForVendor?.uuidString ?? "")

        case .getName:
            print("\(method.rawValue) called.")
            result(UIDevice.current.name)

        case .setName:
            print("\(method.rawValue) called.")
            result(FlutterError(code: "", message: "It can't modify device name from program in iOS", details: nil))

        case .getDeviceBondState:
            print("\(method.rawValue) called.")
            result(bluetoothManager?.deviceBondState(at: call.arguments as? String ?? ""))

        case .removeDeviceBond:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .bondDevice:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .pairingRequestHandlingEnable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .pairingRequestHandlingDisable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getBondedDevices:
            print("\(method.rawValue) called.")
            result(bluetoothManager?.bondedDevice())

        case .isDiscovering:
            print("\(method.rawValue) called.")
            result(bluetoothManager?.isDiscovering)

        case .startDiscovery:
            print("\(method.rawValue) called.")
            bluetoothManager?.startDiscovery()
            result(nil)

        case .cancelDiscovery:
            print("\(method.rawValue) called.")
            bluetoothManager?.cancelDiscovery()
            result(nil)

        case .isDiscoverable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .requestDiscoverable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .connect:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .write:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
}

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

    private var centralManager: CBCentralManager?
    private var scannedPeripherals: [(peripheral: CBPeripheral, rssi: Int)] = []

    override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("manager state: \(String(describing: centralManager?.state))")
    }

    func connect(with argument: Any?) throws {
//        let data = FlutterStandardDataType(rawValue: argument)
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
    func convertToStateNumber(from state: CBManagerState) -> Int {
        switch state {
        case .unknown:
            return state.rawValue
        case .unsupported, .unauthorized, .resetting: // TODO: set "right" number
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

class StateEventChannelStreamHandler: NSObject, FlutterStreamHandler {
    private(set) var stateSink: FlutterEventSink?

    public func sink(stateInteger: Int) {
        stateSink?(stateInteger)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        stateSink = events

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stateSink = nil

        return nil
    }
}

class DiscoveryEventChannelStreamHandler: NSObject, FlutterStreamHandler {
    private(set) var discoverySink: FlutterEventSink?

    public func sink(argument: Any?) {
        discoverySink?(argument)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        discoverySink = events

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        discoverySink = nil

        return nil
    }
}

