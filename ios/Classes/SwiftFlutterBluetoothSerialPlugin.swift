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

public class SwiftFlutterBluetoothSerialPlugin: NSObject, FlutterPlugin {
    private static let stateEventChannelStreamHandler = StateEventChannelStreamHandler()
    private static let discveryEventChannelStreamHandler = DiscoveryEventChannelStreamHandler()

    private var centralManager: CBCentralManager?
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
        if !isInitialized {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            isInitialized = true
        }

        guard let method = FlutterMethodName(rawValue: call.method) else {
            result("unknown method '\(call.method)' called.")
            return
        }

        switch method {
        case .isAvailable:
            result(true)

        case .isOn:
            result(true)

        case .isEnabled:
            result(true)

        case .openSettings:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .requestEnable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .requestDisable:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .ensurePermissions:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getState:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getAddress:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getName:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .setName:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .getDeviceBondState:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

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
            result("iOS " + UIDevice.current.systemVersion)

        case .isDiscovering:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .startDiscovery:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

        case .cancelDiscovery:
            print("\(method.rawValue) called.")
            result("iOS " + UIDevice.current.systemVersion)

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


extension SwiftFlutterBluetoothSerialPlugin: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            NSLog("poweredOn")
            //startScan()
        case .poweredOff:
            // Alert user to turn on Bluetooth
            NSLog("poweredOff")
        case .resetting:
            // Wait for next state update and consider logging interruption of Bluetooth service
            NSLog("resetting")
        case .unauthorized:
            // Alert user to enable Bluetooth permission in app Settings
            NSLog("unauthorized")
        case .unsupported:
            // Alert user their device does not support Bluetooth and app will not work as expected
            NSLog("unsupported")
        case .unknown:
            // Wait for next state update
            NSLog("unknown")
        }
    }
}

class StateEventChannelStreamHandler: NSObject, FlutterStreamHandler {
    private(set) var stateSink: FlutterEventSink?

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

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        discoverySink = events

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        discoverySink = nil

        return nil
    }
}
