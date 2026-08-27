public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293.`3`.`1` {

    public struct Header: Hashable, Sendable {

        public let sourcePort: RFC_9293.Port

        public let destinationPort: RFC_9293.Port

        public let sequenceNumber: RFC_9293.SequenceNumber

        public let acknowledgmentNumber: RFC_9293.SequenceNumber

        public let dataOffset: DataOffset

        public let flags: Flags

        public let window: UInt16

        public let checksum: UInt16

        public let urgentPointer: UInt16

        public let options: [Byte]

        private init(
            __unchecked: Void,
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.sourcePort = sourcePort
            self.destinationPort = destinationPort
            self.sequenceNumber = sequenceNumber
            self.acknowledgmentNumber = acknowledgmentNumber
            self.dataOffset = dataOffset
            self.flags = flags
            self.window = window
            self.checksum = checksum
            self.urgentPointer = urgentPointer
            self.options = options
        }

        public init(
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.init(
                __unchecked: (),
                sourcePort: sourcePort,
                destinationPort: destinationPort,
                sequenceNumber: sequenceNumber,
                acknowledgmentNumber: acknowledgmentNumber,
                dataOffset: dataOffset,
                flags: flags,
                window: window,
                checksum: checksum,
                urgentPointer: urgentPointer,
                options: options
            )
        }

    }
}

extension RFC_9293.`3`.`1`.Header {

    public init(
        sourcePort: RFC_9293.Port,
        destinationPort: RFC_9293.Port,
        sequenceNumber: RFC_9293.SequenceNumber,
        acknowledgmentNumber: RFC_9293.SequenceNumber,
        flags: RFC_9293.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16
    ) {
        self.init(
            __unchecked: (),
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            dataOffset: .minimum,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: []
        )
    }
}

extension RFC_9293.`3`.`1`.Header {

    public init<Bytes: Swift.Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= 20 else { throw .insufficientBytes }

        var iterator = bytes.makeIterator()

        func next() -> UInt8 {
            iterator.next()!.underlying
        }

        let srcHi = next()
        let srcLo = next()
        let srcPort = RFC_9293.Port(UInt16(srcHi) << 8 | UInt16(srcLo))

        let dstHi = next()
        let dstLo = next()
        let dstPort = RFC_9293.Port(UInt16(dstHi) << 8 | UInt16(dstLo))

        let seq0 = next()
        let seq1 = next()
        let seq2 = next()
        let seq3 = next()
        let seqValue = UInt32(seq0) << 24 | UInt32(seq1) << 16 | UInt32(seq2) << 8 | UInt32(seq3)
        let seqNum = RFC_9293.SequenceNumber(rawValue: seqValue)

        let ack0 = next()
        let ack1 = next()
        let ack2 = next()
        let ack3 = next()
        let ackValue = UInt32(ack0) << 24 | UInt32(ack1) << 16 | UInt32(ack2) << 8 | UInt32(ack3)
        let ackNum = RFC_9293.SequenceNumber(rawValue: ackValue)

        let offsetByte = next()
        let offsetValue = offsetByte >> 4

        let dataOffset: RFC_9293.`3`.`1`.DataOffset
        let dataOffsetOutcome = Result { () throws(RFC_9293.`3`.`1`.DataOffset.Error) in
            try RFC_9293.`3`.`1`.DataOffset(rawValue: offsetValue)
        }
        switch dataOffsetOutcome {
        case .success(let value):
            dataOffset = value

        case .failure(let error):
            switch error {
            case .valueTooSmall: throw Error.dataOffsetTooSmall
            case .valueTooLarge: throw Error.dataOffsetTooLarge
            case .notAligned: throw Error.dataOffsetTooSmall
            }
        }

        let flagsByte = next()
        let flags = RFC_9293.`3`.`1`.Flags(rawValue: flagsByte)

        let winHi = next()
        let winLo = next()
        let window = UInt16(winHi) << 8 | UInt16(winLo)

        let csHi = next()
        let csLo = next()
        let checksum = UInt16(csHi) << 8 | UInt16(csLo)

        let urgHi = next()
        let urgLo = next()
        let urgentPointer = UInt16(urgHi) << 8 | UInt16(urgLo)

        let optionsLength = dataOffset.optionsLength
        guard bytes.count >= 20 + optionsLength else { throw .insufficientBytes }

        var options: [Byte] = []
        options.reserveCapacity(optionsLength)
        for _ in 0..<optionsLength {
            options.append(Byte(next()))
        }

        self.init(
            __unchecked: (),
            sourcePort: srcPort,
            destinationPort: dstPort,
            sequenceNumber: seqNum,
            acknowledgmentNumber: ackNum,
            dataOffset: dataOffset,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: options
        )
    }
}

extension RFC_9293.`3`.`1`.Header: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: RFC_9293.`3`.`1`.Header,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {

        buffer.append(contentsOf: header.sourcePort.rawValue.bytes(endianness: .big))

        buffer.append(contentsOf: header.destinationPort.rawValue.bytes(endianness: .big))

        buffer.append(contentsOf: header.sequenceNumber.rawValue.bytes(endianness: .big))

        buffer.append(contentsOf: header.acknowledgmentNumber.rawValue.bytes(endianness: .big))

        buffer.append(Byte(header.dataOffset.rawValue << 4))

        buffer.append(Byte(header.flags.rawValue))

        buffer.append(contentsOf: header.window.bytes(endianness: .big))

        buffer.append(contentsOf: header.checksum.bytes(endianness: .big))

        buffer.append(contentsOf: header.urgentPointer.bytes(endianness: .big))

        buffer.append(contentsOf: header.options)
    }
}

extension RFC_9293.`3`.`1`.Header: CustomStringConvertible {
    public var description: String {
        "TCP \(sourcePort) → \(destinationPort) [\(flags)] seq=\(sequenceNumber) ack=\(acknowledgmentNumber) win=\(window)"
    }
}
