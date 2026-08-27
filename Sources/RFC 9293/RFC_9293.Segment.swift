public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293 {

    public struct Segment: Hashable, Sendable {

        public let header: `3`.`1`.Header

        public let data: [Byte]

        private init(__unchecked: Void, header: `3`.`1`.Header, data: [Byte]) {
            self.header = header
            self.data = data
        }

        public init(header: `3`.`1`.Header, data: [Byte]) {
            self.init(__unchecked: (), header: header, data: data)
        }

    }
}

extension RFC_9293.Segment {

    public init(header: RFC_9293.`3`.`1`.Header) {
        self.init(__unchecked: (), header: header, data: [])
    }
}

extension RFC_9293.Segment {

    public var length: Int {
        header.dataOffset.headerLength + data.count
    }

    public var sequenceNumber: RFC_9293.SequenceNumber {
        header.sequenceNumber
    }

    public var nextSequenceNumber: RFC_9293.SequenceNumber {
        var seq = header.sequenceNumber + UInt32(data.count)

        if header.flags.contains(.syn) { seq += 1 }
        if header.flags.contains(.fin) { seq += 1 }

        return seq
    }

    public var segmentLength: UInt32 {
        var len = UInt32(data.count)
        if header.flags.contains(.syn) { len += 1 }
        if header.flags.contains(.fin) { len += 1 }
        return len
    }
}

extension RFC_9293.Segment {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        let header: RFC_9293.`3`.`1`.Header
        let headerOutcome = Result { () throws(RFC_9293.`3`.`1`.Header.Error) in
            try RFC_9293.`3`.`1`.Header(bytes: bytes)
        }
        switch headerOutcome {
        case .success(let value):
            header = value

        case .failure(let error):
            switch error {
            case .insufficientBytes: throw Error.insufficientBytes
            case .dataOffsetTooSmall: throw Error.invalidDataOffset
            case .dataOffsetTooLarge: throw Error.invalidDataOffset
            }
        }

        let headerLength = header.dataOffset.headerLength
        let data = Array(bytes.dropFirst(headerLength))

        self.init(__unchecked: (), header: header, data: data)
    }
}

extension RFC_9293.Segment: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ segment: RFC_9293.Segment,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_9293.`3`.`1`.Header.serialize(segment.header, into: &buffer)
        buffer.append(contentsOf: segment.data)
    }
}

extension RFC_9293.Segment: CustomStringConvertible {
    public var description: String {
        "\(header) len=\(data.count)"
    }
}
