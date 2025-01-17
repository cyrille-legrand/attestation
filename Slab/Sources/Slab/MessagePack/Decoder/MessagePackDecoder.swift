import Foundation

/**
 An object that decodes instances of a data type from MessagePack objects.
 */
public final class MessagePackDecoder {
    public init() {}

    /**
     A dictionary you use to customize the decoding process
     by providing contextual information.
     */
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    /**
     Returns a value of the type you specify,
     decoded from a MessagePack object.

     - Parameters:
        - type: The type of the value to decode
                from the supplied MessagePack object.
        - data: The MessagePack object to decode.
     - Throws: `DecodingError.dataCorrupted(_:)`
               if the data is not valid MessagePack.
     */
    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let decoder = _MessagePackDecoder(data: data)
        decoder.userInfo = userInfo

        switch type {
            case is Data.Type:
                let box = try Box<Data>(from: decoder)
                return box.value as! T
            case is Date.Type:
                let box = try Box<Date>(from: decoder)
                return box.value as! T
            default:
                return try T(from: decoder)
        }
    }
}

// MARK: -

final class _MessagePackDecoder {
    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] = [:]

    var container: MessagePackDecodingContainer?
    private var data: Data

    init(data: Data) {
        self.data = data
    }
}

extension _MessagePackDecoder: Decoder {
    fileprivate func assertCanCreateContainer() {
        precondition(container == nil)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedDecodingContainer<Key> where Key: CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(data: data, codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedDecodingContainer {
        assertCanCreateContainer()

        let container = UnkeyedContainer(data: data, codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return container
    }

    func singleValueContainer() -> SingleValueDecodingContainer {
        assertCanCreateContainer()

        let container = SingleValueContainer(data: data, codingPath: codingPath, userInfo: userInfo)
        self.container = container

        return container
    }
}

protocol MessagePackDecodingContainer: AnyObject {
    var codingPath: [CodingKey] { get set }

    var userInfo: [CodingUserInfoKey: Any] { get }

    var data: Data { get set }
    var index: Data.Index { get set }
}

extension MessagePackDecodingContainer {
    func readByte() throws -> UInt8 {
        try read(1).first!
    }

    func read(_ length: Int) throws -> Data {
        let nextIndex = index.advanced(by: length)
        guard nextIndex <= data.endIndex else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Unexpected end of data")
            throw DecodingError.dataCorrupted(context)
        }
        defer { self.index = nextIndex }

        return data.subdata(in: index ..< nextIndex)
    }

    func read<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
        let stride = MemoryLayout<T>.stride
        let bytes = [UInt8](try read(stride))
        return T(bytes: bytes)
    }
}
