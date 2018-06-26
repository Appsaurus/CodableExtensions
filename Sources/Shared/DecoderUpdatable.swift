//
//  DecoderUpdatable.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 4/27/18.
//

#if !os(watchOS)
import Foundation
import RuntimeExtensions
import Runtime

public struct DynamicCodingKey: CodingKey {
	public var stringValue: String

	public init(stringValue: String) {
		self.stringValue = stringValue
	}

	public var intValue: Int?

	public init?(intValue: Int) {
		self.init(stringValue: "\(intValue)")
		self.intValue = intValue
	}
}

public enum DecoderUpdatingOptionalStrategy{
	case requireExplicitNull
	case interpretMissingKeyAsNull
}
extension Encodable{
//	public func encodeReflectively(to encoder: Encoder) throws{
//		try reflectToDictionary(object: self).toAnyCodableDictionary().encode(to: encoder)
//	}
}
extension Decodable {
	@discardableResult
	public mutating func update(with data: Data, using decoder: JSONDecoder = .defaultDecoder) throws -> Self{
		try decoder.update(&self, from: data)
		return self
	}
	public mutating func update(from decoder: Decoder, overwritesMissingKeysAsNilValues: Bool = false) throws{
		let container: KeyedDecodingContainer<DynamicCodingKey> = try decoder.container(keyedBy: DynamicCodingKey.self)
		let reflectedProperties = try properties(self)
		for property in reflectedProperties{
			try setTypedValue(for: property, using: container)
		}
	}
}

extension Decodable {

	public mutating func setTypedValue(for property: PropertyInfo,
									   using container: KeyedDecodingContainer<DynamicCodingKey>,
									   overwritesMissingKeysAsNilValues: Bool = false) throws{
		let key = property.name
		let codingKey = DynamicCodingKey(stringValue: key)
		guard overwritesMissingKeysAsNilValues || container.contains(codingKey) else { return }
		guard let value = try container.decodeTypeErasedValue(property.type, forKey: key) else { return }
		try set(value, key: key, for: &self)
	}
}

extension KeyedDecodingContainer where K == DynamicCodingKey{
	public func decodeTypeErasedValue(_ type: Any.Type,
									  forKey key: String) throws -> Optional<Any>{
		let codingKey = DynamicCodingKey(stringValue: key)
		guard contains(codingKey) else { return nil }
		switch type{
		case is Optional<String>.Type:
			return try decodeIfPresent(String.self, forKey: codingKey) as Any
		case is Optional<Bool>.Type:
			return try decodeIfPresent(Bool.self, forKey: codingKey) as Any
		case is Optional<Double>.Type:
			return try decodeIfPresent(Double.self, forKey: codingKey) as Any
		case is Optional<Int>.Type:
			return try decodeIfPresent(Int.self, forKey: codingKey) as Any
		case is Optional<Data>.Type:
			return try decodeIfPresent(Data.self, forKey: codingKey) as Any
		case is Optional<Date>.Type:
			return try decodeIfPresent(Date.self, forKey: codingKey) as Any
		case is String.Type:
			return try decode(String.self, forKey: codingKey) as Any
		case is Bool.Type:
			return try decode(Bool.self, forKey: codingKey) as Any
		case is Double.Type:
			return try decode(Double.self, forKey: codingKey) as Any
		case is Int.Type:
			return try decode(Int.self, forKey: codingKey) as Any
		case is Data.Type:
			return try decode(Data.self, forKey: codingKey) as Any
		case is Date.Type:
			return try decode(Date.self, forKey: codingKey) as Any
		default: return nil
		}
	}
}

public protocol DecodingFormat {
	func decoder(for data: Data) -> Decoder
}

extension DecodingFormat {
	public func update<T: Decodable>(_ value: inout T, from data: Data) throws {
		try value.update(from: decoder(for: data))
	}

	public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
		return try T.init(from: decoder(for: data))
	}
}

public struct DecoderExtractor: Decodable {
	public let decoder: Decoder

	public init(from decoder: Decoder) throws {
		self.decoder = decoder
	}
}

extension JSONDecoder: DecodingFormat {
	public func decoder(for data: Data) -> Decoder {
		// Can try! here because DecoderExtractor's init(from: Decoder) never throws
		return try! decode(DecoderExtractor.self, from: data).decoder
	}
}


public class NestedDecoder<Key: CodingKey>: Decoder {
	public let container: KeyedDecodingContainer<Key>
	public let key: Key

	public init(from container: KeyedDecodingContainer<Key>, key: Key, userInfo: [CodingUserInfoKey : Any] = [:]) {
		self.container = container
		self.key = key
		self.userInfo = userInfo
	}

	public var userInfo: [CodingUserInfoKey : Any]

	public var codingPath: [CodingKey] {
		return container.codingPath
	}

	public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return try container.nestedContainer(keyedBy: type, forKey: key)
	}

	public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		return try container.nestedUnkeyedContainer(forKey: key)
	}

	public func singleValueContainer() throws -> SingleValueDecodingContainer {
		return NestedSingleValueDecodingContainer(container: container, key: key)
	}
}

public class NestedSingleValueDecodingContainer<Key: CodingKey>: SingleValueDecodingContainer {
	public let container: KeyedDecodingContainer<Key>
	public let key: Key
	public var codingPath: [CodingKey] {
		return container.codingPath
	}

	public init(container: KeyedDecodingContainer<Key>, key: Key) {
		self.container = container
		self.key = key
	}

	public func decode(_ type: Bool.Type) throws -> Bool {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Int.Type) throws -> Int {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Int8.Type) throws -> Int8 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Int16.Type) throws -> Int16 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Int32.Type) throws -> Int32 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Int64.Type) throws -> Int64 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: UInt.Type) throws -> UInt {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: UInt8.Type) throws -> UInt8 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: UInt16.Type) throws -> UInt16 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: UInt32.Type) throws -> UInt32 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: UInt64.Type) throws -> UInt64 {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Float.Type) throws -> Float {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: Double.Type) throws -> Double {
		return try container.decode(type, forKey: key)
	}

	public func decode(_ type: String.Type) throws -> String {
		return try container.decode(type, forKey: key)
	}

	public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		return try container.decode(type, forKey: key)
	}

	public func decodeNil() -> Bool {
		return (try? container.decodeNil(forKey: key)) ?? false
	}
}

extension KeyedDecodingContainer {
	public func update<T: Decodable>(_ value: inout T, forKey key: Key, userInfo: [CodingUserInfoKey : Any] = [:]) throws {
		let nestedDecoder = NestedDecoder(from: self, key: key, userInfo: userInfo)
		try value.decodeReflectively(from: nestedDecoder)
	}
}
#endif
