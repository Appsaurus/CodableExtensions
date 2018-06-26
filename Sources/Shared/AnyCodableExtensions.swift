//
//  AnyCodableExtensions.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/21/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation
import Codability

//MARK: AnyCodable wrapping and unwrapping convenience
extension Dictionary where Key == String {

	public func anyCodableUnwrapped() -> [String : Any] {
		var dictionary: [String : Any] = [:]
		for (key, value) in self{
			dictionary[key] = AnyCodable.unwrapValue(value)
		}
		return dictionary
	}

	public func toAnyCodableDictionary() throws -> AnyCodableDictionary {
		if let alreadyAnyCodable = self as? AnyCodableDictionary{
			return alreadyAnyCodable
		}
		return self.mapValues({AnyCodable.wrap($0)})		
	}
}

extension AnyCodable{
	public static func unwrapValue(_ object: Any) -> Any {
		if let anyCodable = object as? AnyCodable{
			return anyCodable.value
		}
		return object
	}
}

extension Encodable{
	public func toAnyCodableDictionary(using encoder: JSONEncoder = .defaultEncoder, using decoder: JSONDecoder = .defaultDecoder) throws -> AnyCodableDictionary{
		return try toAnyDictionary(using: encoder, decoder: decoder).toAnyCodableDictionary()
	}

	public func wrapAsAnyCodable() -> AnyCodable{
		return AnyCodable.wrap(self)
	}
}

extension AnyCodable{
	public static func wrap(_ any: Any) -> AnyCodable{
		if let alreadyAnyCodable = any as? AnyCodable{
			return alreadyAnyCodable
		}
		return AnyCodable(any)
	}
}
