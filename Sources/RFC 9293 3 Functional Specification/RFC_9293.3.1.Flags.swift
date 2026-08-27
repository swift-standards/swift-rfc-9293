public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293.`3`.`1` {

    public struct Flags: OptionSet, Hashable, Sendable, Codable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_9293.`3`.`1`.Flags {

    public static let fin = Self(rawValue: 1 << 0)

    public static let syn = Self(rawValue: 1 << 1)

    public static let rst = Self(rawValue: 1 << 2)

    public static let psh = Self(rawValue: 1 << 3)

    public static let ack = Self(rawValue: 1 << 4)

    public static let urg = Self(rawValue: 1 << 5)

    public static let ece = Self(rawValue: 1 << 6)

    public static let cwr = Self(rawValue: 1 << 7)
}

extension RFC_9293.`3`.`1`.Flags {

    public static let none = Self([])

    public static let synAck: Self = [.syn, .ack]

    public static let finAck: Self = [.fin, .ack]
}

extension RFC_9293.`3`.`1`.Flags: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ flags: RFC_9293.`3`.`1`.Flags,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(Byte(flags.rawValue))
    }
}

extension RFC_9293.`3`.`1`.Flags: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.cwr) { parts.append("CWR") }
        if contains(.ece) { parts.append("ECE") }
        if contains(.urg) { parts.append("URG") }
        if contains(.ack) { parts.append("ACK") }
        if contains(.psh) { parts.append("PSH") }
        if contains(.rst) { parts.append("RST") }
        if contains(.syn) { parts.append("SYN") }
        if contains(.fin) { parts.append("FIN") }
        return parts.isEmpty ? "none" : parts.joined(separator: "|")
    }
}
