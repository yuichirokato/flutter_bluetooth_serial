import Flutter
import Foundation

class DiscoveryEventChannelStreamHandler: NSObject, FlutterStreamHandler {
    private(set) var discoverySink: FlutterEventSink?

    func sink(argument: Any?) {
        discoverySink?(argument)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        discoverySink = events

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        discoverySink = nil

        return nil
    }
}
