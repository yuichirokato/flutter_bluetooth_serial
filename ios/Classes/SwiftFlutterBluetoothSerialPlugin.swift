import Flutter
import UIKit
import CoreBluetooth

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

enum FlutterChannelName: String {
    case bluetoothSerialMethod = "flutter_bluetooth_serial/methods"
    case bluetoothSerialState = "flutter_bluetooth_serial/state"
    case bluetoothSerialDiscovery = "flutter_bluetooth_serial/discovery"
}

public class SwiftFlutterBluetoothSerialPlugin: NSObject, FlutterPlugin {
    private static let stateEventChannelStreamHandler = StateEventChannelStreamHandler()
    private static let discveryEventChannelStreamHandler = DiscoveryEventChannelStreamHandler()

    private var bluetoothManager: BluetoothManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(name: FlutterChannelName.bluetoothSerialMethod.rawValue, binaryMessenger: messenger)
        let instance = SwiftFlutterBluetoothSerialPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let stateChannel = FlutterEventChannel(name: FlutterChannelName.bluetoothSerialState.rawValue, binaryMessenger: messenger)
        stateChannel.setStreamHandler(stateEventChannelStreamHandler)

        let discoveryChannel = FlutterEventChannel(name: FlutterChannelName.bluetoothSerialDiscovery.rawValue, binaryMessenger: messenger)
        discoveryChannel.setStreamHandler(discveryEventChannelStreamHandler)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if bluetoothManager == nil {
            bluetoothManager = BluetoothManager(stateEventChannelStreamHandler: SwiftFlutterBluetoothSerialPlugin.stateEventChannelStreamHandler,
                                                discveryEventChannelStreamHandler: SwiftFlutterBluetoothSerialPlugin.discveryEventChannelStreamHandler)
        }

        guard let method = FlutterMethodName(rawValue: call.method) else {
            result(FlutterError(code: "-1", message: "unknown method '\(call.method)' called.", details: nil))
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
            result(FlutterError(code: "-1", message: "It can't modify device name from App in iOS", details: nil))

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
