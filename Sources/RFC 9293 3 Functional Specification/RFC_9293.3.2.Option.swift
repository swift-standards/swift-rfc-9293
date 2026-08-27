public import Binary_Serializable
import Standard_Library_Extensions

extension RFC_9293.`3`.`2` {

    public enum Option: Hashable, Sendable {

        case endOfOptionList

        case noOperation

        case maximumSegmentSize(UInt16)

        case windowScale(UInt8)

        case sackPermitted

        case sack([SACK.Block])

        case timestamps(value: UInt32, echoReply: UInt32)

        case unknown(kind: UInt8, data: [Byte])
    }
}

extension RFC_9293.`3`.`2` {

    public enum SACK {}
}

extension RFC_9293.`3`.`2`.SACK {

    public struct Block: Hashable, Sendable, Codable {

        public let leftEdge: RFC_9293.SequenceNumber

        public let rightEdge: RFC_9293.SequenceNumber

        public init(leftEdge: RFC_9293.SequenceNumber, rightEdge: RFC_9293.SequenceNumber) {
            self.leftEdge = leftEdge
            self.rightEdge = rightEdge
        }
    }
}

extension RFC_9293.`3`.`2`.Option {

    public enum Kind: UInt8, Hashable, Sendable {
        case endOfOptionList = 0
        case noOperation = 1
        case maximumSegmentSize = 2
        case windowScale = 3
        case sackPermitted = 4
        case sack = 5
        case timestamps = 8
    }
}

extension RFC_9293.`3`.`2`.Option {

    public var kind: UInt8 {
        switch self {
        case .endOfOptionList: return 0
        case .noOperation: return 1
        case .maximumSegmentSize: return 2
        case .windowScale: return 3
        case .sackPermitted: return 4
        case .sack: return 5
        case .timestamps: return 8
        case .unknown(let k, _): return k
        }
    }

    public var length: Int {
        switch self {
        case .endOfOptionList: return 1
        case .noOperation: return 1
        case .maximumSegmentSize: return 4
        case .windowScale: return 3
        case .sackPermitted: return 2
        case .sack(let blocks): return 2 + (blocks.count * 8)
        case .timestamps: return 10
        case .unknown(_, let data): return 2 + data.count
        }
    }
}

extension RFC_9293.`3`.`2`.Option {

    public static func parse<Bytes: Swift.Collection>(
        from bytes: Bytes
    ) throws(Error) -> (option: Self, consumed: Int)
    where Bytes.Element == Byte {
        var iterator = bytes.makeIterator()

        func nextByte() -> UInt8? {
            iterator.next()?.underlying
        }

        guard let kind = nextByte() else {
            throw .insufficientBytes
        }

        switch kind {
        case 0:
            return (.endOfOptionList, 1)

        case 1:
            return (.noOperation, 1)

        case 2:
            guard let length = nextByte(), length == 4 else {
                throw .invalidLength
            }
            guard let hi = nextByte(), let lo = nextByte() else {
                throw .insufficientBytes
            }
            let mss = UInt16(hi) << 8 | UInt16(lo)
            return (.maximumSegmentSize(mss), 4)

        case 3:
            guard let length = nextByte(), length == 3 else {
                throw .invalidLength
            }
            guard let shift = nextByte() else {
                throw .insufficientBytes
            }
            return (.windowScale(shift), 3)

        case 4:
            guard let length = nextByte(), length == 2 else {
                throw .invalidLength
            }
            return (.sackPermitted, 2)

        case 5:
            guard let length = nextByte() else {
                throw .insufficientBytes
            }
            let dataLength = Int(length) - 2
            guard dataLength >= 0, dataLength % 8 == 0 else {
                throw .invalidLength
            }

            var blocks: [RFC_9293.`3`.`2`.SACK.Block] = []
            let blockCount = dataLength / 8
            blocks.reserveCapacity(blockCount)

            for _ in 0..<blockCount {
                guard let l0 = nextByte(), let l1 = nextByte(),
                    let l2 = nextByte(), let l3 = nextByte(),
                    let r0 = nextByte(), let r1 = nextByte(),
                    let r2 = nextByte(), let r3 = nextByte()
                else {
                    throw .insufficientBytes
                }
                let left = UInt32(l0) << 24 | UInt32(l1) << 16 | UInt32(l2) << 8 | UInt32(l3)
                let right = UInt32(r0) << 24 | UInt32(r1) << 16 | UInt32(r2) << 8 | UInt32(r3)
                blocks.append(
                    RFC_9293.`3`.`2`.SACK.Block(
                        leftEdge: RFC_9293.SequenceNumber(rawValue: left),
                        rightEdge: RFC_9293.SequenceNumber(rawValue: right)
                    )
                )
            }
            return (.sack(blocks), Int(length))

        case 8:
            guard let length = nextByte(), length == 10 else {
                throw .invalidLength
            }
            guard let v0 = nextByte(), let v1 = nextByte(),
                let v2 = nextByte(), let v3 = nextByte(),
                let e0 = nextByte(), let e1 = nextByte(),
                let e2 = nextByte(), let e3 = nextByte()
            else {
                throw .insufficientBytes
            }
            let value = UInt32(v0) << 24 | UInt32(v1) << 16 | UInt32(v2) << 8 | UInt32(v3)
            let echo = UInt32(e0) << 24 | UInt32(e1) << 16 | UInt32(e2) << 8 | UInt32(e3)
            return (.timestamps(value: value, echoReply: echo), 10)

        default:
            guard let length = nextByte() else {
                throw .insufficientBytes
            }
            let dataLength = Int(length) - 2
            guard dataLength >= 0 else {
                throw .invalidLength
            }

            var data: [Byte] = []
            data.reserveCapacity(dataLength)
            for _ in 0..<dataLength {
                guard let byte = nextByte() else {
                    throw .insufficientBytes
                }
                data.append(Byte(byte))
            }
            return (.unknown(kind: kind, data: data), Int(length))
        }
    }

    public static func parseAll<Bytes: Swift.Collection>(
        from bytes: Bytes
    ) throws(Error) -> [Self]
    where Bytes.Element == Byte {
        var options: [Self] = []
        var remaining = Array(bytes)

        while !remaining.isEmpty {
            let (option, consumed) = try parse(from: remaining)
            options.append(option)

            if case .endOfOptionList = option {
                break
            }

            remaining.removeFirst(consumed)
        }

        return options
    }
}

extension RFC_9293.`3`.`2`.Option: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ option: RFC_9293.`3`.`2`.Option,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        switch option {
        case .endOfOptionList:
            buffer.append(0)

        case .noOperation:
            buffer.append(1)

        case .maximumSegmentSize(let mss):
            buffer.append(2)
            buffer.append(4)
            buffer.append(contentsOf: mss.bytes(endianness: .big))

        case .windowScale(let shift):
            buffer.append(3)
            buffer.append(3)

            buffer.append(Byte(shift))

        case .sackPermitted:
            buffer.append(4)
            buffer.append(2)

        case .sack(let blocks):
            buffer.append(5)
            buffer.append(Byte(UInt8(2 + blocks.count * 8)))
            for block in blocks {
                buffer.append(contentsOf: block.leftEdge.rawValue.bytes(endianness: .big))
                buffer.append(contentsOf: block.rightEdge.rawValue.bytes(endianness: .big))
            }

        case .timestamps(let value, let echoReply):
            buffer.append(8)
            buffer.append(10)
            buffer.append(contentsOf: value.bytes(endianness: .big))
            buffer.append(contentsOf: echoReply.bytes(endianness: .big))

        case .unknown(let kind, let data):

            buffer.append(Byte(kind))
            buffer.append(Byte(UInt8(2 + data.count)))

            buffer.append(contentsOf: data)
        }
    }
}

extension RFC_9293.`3`.`2`.Option: CustomStringConvertible {
    public var description: String {
        switch self {
        case .endOfOptionList:
            return "EOL"

        case .noOperation:
            return "NOP"

        case .maximumSegmentSize(let mss):
            return "MSS=\(mss)"

        case .windowScale(let shift):
            return "WS=\(shift)"

        case .sackPermitted:
            return "SACK-OK"

        case .sack(let blocks):
            let ranges = blocks.map { "\($0.leftEdge)-\($0.rightEdge)" }
            return "SACK[\(ranges.joined(separator: ","))]"

        case .timestamps(let value, let echo):
            return "TS=\(value)/\(echo)"

        case .unknown(let kind, _):
            return "OPT(\(kind))"
        }
    }
}
