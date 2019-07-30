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
public extension Dictionary where Key == String {

	func anyCodableUnwrapped() -> [String : Any] {
		var dictionary: [String : Any] = [:]
		for (key, value) in self{
			dictionary[key] = AnyCodable.unwrapAnyCodable(value)
		}
		return dictionary
	}

	func toAnyCodableDictionary() throws -> AnyCodableDictionary {
		if let alreadyAnyCodable = self as? AnyCodableDictionary{
			return alreadyAnyCodable
		}
		return self.mapValues({AnyCodable.wrapAnyCodable($0)})		
	}
}

public extension AnyCodable{
	static func unwrapAnyCodable(_ object: Any) -> Any {
		if let anyCodable = object as? AnyCodable{
			return anyCodable.value
		}
		return object
	}
}

public extension Encodable{
	func toAnyCodableDictionary(encoder: JSONEncoder = .default, decoder: JSONDecoder = .default) throws -> AnyCodableDictionary{
		return try toAnyDictionary(encoder: encoder, decoder: decoder).toAnyCodableDictionary()
	}

	func wrapAsAnyCodable() -> AnyCodable{
		return AnyCodable.wrapAnyCodable(self)
	}
}

public extension AnyCodable{
    static func wrapAnyCodable(_ any: Any) -> AnyCodable{
		if let alreadyAnyCodable = any as? AnyCodable{
			return alreadyAnyCodable
		}
		return AnyCodable(any)
	}
}
