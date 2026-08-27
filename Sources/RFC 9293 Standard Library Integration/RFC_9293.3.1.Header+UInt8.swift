internal import Byte
public import RFC_9293_3_Functional_Specification
public import RFC_9293_Shared

extension RFC_9293.`3`.`1`.Header {

    @_disfavoredOverload
    public init(
        sourcePort: RFC_9293.Port,
        destinationPort: RFC_9293.Port,
        sequenceNumber: RFC_9293.SequenceNumber,
        acknowledgmentNumber: RFC_9293.SequenceNumber,
        dataOffset: RFC_9293.`3`.`1`.DataOffset,
        flags: RFC_9293.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16,
        options: [UInt8]
    ) {
        self.init(
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            dataOffset: dataOffset,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: [Byte](options.lazy.map(Byte.init))
        )
    }
}
