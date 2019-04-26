//
//  CodableDefaults.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/21/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation

//MARK: JSONCodableDefaults
public class CodableDefaults{
	public static var jsonEncoder: JSONEncoder = JSONEncoder(.custom_iso8601)
	public static var jsonDecoder: JSONDecoder = JSONDecoder(.custom_iso8601)
}

extension JSONEncoder {
	static public let defaultEncoder = CodableDefaults.jsonEncoder
}


extension JSONDecoder {
	static public let defaultDecoder = CodableDefaults.jsonDecoder
}

extension JSONDecoder{
	public convenience init(_ dateDecodingStrategy: DateDecodingStrategy){
		self.init()
		self.dateDecodingStrategy = dateDecodingStrategy
	}
}

extension JSONEncoder{
	public convenience init(_ dateEncodingStrategy: DateEncodingStrategy){
		self.init()
		self.dateEncodingStrategy = dateEncodingStrategy
	}

}

extension JSONDecoder{
    public func decodeNested<D: Decodable>(codableType: D.Type = D.self, from data: Data, at key: String) throws -> D?{
        return try decode([String: D].self, from: data)[key]
    }
}
