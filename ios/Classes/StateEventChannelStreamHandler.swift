import Flutter
import Foundation

class StateEventChannelStreamHandler: NSObject, FlutterStreamHandler {
    private(set) var stateSink: FlutterEventSink?

    func sink(stateInteger: Int) {
        stateSink?(stateInteger)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        stateSink = events

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stateSink = nil

        return nil
    }
}
