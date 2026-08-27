public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293 {

    public struct SequenceNumber: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt32

        private init(__unchecked: Void, rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt32) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

extension RFC_9293.SequenceNumber: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        Int32(bitPattern: lhs.rawValue &- rhs.rawValue) < 0
    }
}

extension RFC_9293.SequenceNumber {

    public static func + (lhs: Self, rhs: UInt32) -> Self {
        Self(rawValue: lhs.rawValue &+ rhs)
    }

    public static func += (lhs: inout Self, rhs: UInt32) {
        lhs = lhs + rhs
    }

    public static func - (lhs: Self, rhs: Self) -> UInt32 {
        lhs.rawValue &- rhs.rawValue
    }
}

extension RFC_9293.SequenceNumber {

    public func isWithin(left: Self, right: Self) -> Bool {
        left <= self && self <= right
    }

    public func isBetween(left: Self, right: Self) -> Bool {
        left < self && self < right
    }
}

extension RFC_9293.SequenceNumber {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= 4 else { throw .insufficientBytes }

        var iterator = bytes.makeIterator()

        let b0 = iterator.next()!.underlying
        let b1 = iterator.next()!.underlying
        let b2 = iterator.next()!.underlying
        let b3 = iterator.next()!.underlying

        let value = UInt32(b0) << 24 | UInt32(b1) << 16 | UInt32(b2) << 8 | UInt32(b3)
        self.init(__unchecked: (), rawValue: value)
    }
}

extension RFC_9293.SequenceNumber: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ seq: RFC_9293.SequenceNumber,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: seq.rawValue.bytes(endianness: .big))
    }
}

extension RFC_9293.SequenceNumber: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
