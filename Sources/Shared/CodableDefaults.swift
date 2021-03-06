//
//  CodableDefaults.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/21/18.
//  Copyright © 2018 Brian Strobach. All rights reserved.
//

import Foundation

//MARK: JSONCodableDefaults

public extension JSONEncoder {
	static var `default` = JSONEncoder(.iso8601)
}


public extension JSONDecoder {
	static var `default` = JSONDecoder(.iso8601)
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
