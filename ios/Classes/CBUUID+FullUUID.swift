import CoreBluetooth

extension CBUUID {
    var fullUUIDString: String {
        uuidString.count == 4
            ? String(format: "0000%@-0000-1000-8000-00805F9B34FB", uuidString)
            : uuidString.lowercased()
    }
}
