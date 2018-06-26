//
//  CodableRetrofitted.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/23/18.
//

import Foundation
import RuntimeExtensions
import Codability
/// Protocol that implements encoding and decoding via reflection. Can be used for non codable classes that you want to
/// extend to be Codable, but do not have control over the defining class and therefore cannot synthesize Codable implementation.
public typealias ReflectionCodable = ReflectionEncodable & Decodable

public protocol ReflectionEncodable: Encodable{
	func encodeReflectively(to encoder: Encoder) throws
}

extension ReflectionEncodable{
	public func encode(to encoder: Encoder) throws {
		try encodeReflectively(to: encoder)
	}
}

extension Encodable{
	public func encodeReflectively(to encoder: Encoder) throws{
		try reflectToDictionary(object: self).toAnyCodableDictionary().encode(to: encoder)
	}
}

extension Decodable {

	public mutating func decodeReflectively(from decoder: Decoder, overwritesMissingKeysAsNilValues: Bool = false) throws{
		let container: KeyedDecodingContainer<DynamicCodingKey> = try decoder.container(keyedBy: DynamicCodingKey.self)
		let reflectedProperties = try properties(self)
		for property in reflectedProperties{
			try setTypedValue(for: property, using: container)
		}
	}
}
