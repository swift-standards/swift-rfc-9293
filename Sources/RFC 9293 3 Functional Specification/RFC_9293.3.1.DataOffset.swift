public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293.`3`.`1` {

    public struct DataOffset: Hashable, Sendable, Codable {

        public let rawValue: UInt8

        private init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt8) throws(Error) {
            guard rawValue >= 5 else { throw .valueTooSmall }
            guard rawValue <= 15 else { throw .valueTooLarge }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

extension RFC_9293.`3`.`1`.DataOffset {

    public static let minimum = Self(__unchecked: (), rawValue: 5)

    public static let maximum = Self(__unchecked: (), rawValue: 15)
}

extension RFC_9293.`3`.`1`.DataOffset {

    public var headerLength: Int {
        Int(rawValue) * 4
    }

    public var optionsLength: Int {
        headerLength - 20
    }
}

extension RFC_9293.`3`.`1`.DataOffset {

    public static func fromHeaderLength(_ bytes: Int) throws(Error) -> Self {
        guard bytes >= 20 else { throw .valueTooSmall }
        guard bytes <= 60 else { throw .valueTooLarge }
        guard bytes % 4 == 0 else { throw .notAligned }
        return Self(__unchecked: (), rawValue: UInt8(bytes / 4))
    }
}

extension RFC_9293.`3`.`1`.DataOffset: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ offset: RFC_9293.`3`.`1`.DataOffset,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(Byte(offset.rawValue << 4))
    }
}

extension RFC_9293.`3`.`1`.DataOffset: CustomStringConvertible {
    public var description: String {
        "\(rawValue) (\(headerLength) bytes)"
    }
}
