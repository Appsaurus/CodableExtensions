//
//  Codable+URLQueryItems.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/30/19.
//

import Foundation

public extension Decodable {
    static func decode(from items: [URLQueryItem], using decoder: URLQueryItemsDecoder = URLQueryItemsDecoder()) throws -> Self {
        return try decoder.decode(Self.self, from: items)
    }
}

public extension Encodable {
    func encodeAsURLQueryItems(using encoder: URLQueryItemsEncoder = URLQueryItemsEncoder()) throws -> [URLQueryItem] {
        return try encoder.encode(self)
    }
}
public extension Array where Element == URLQueryItem {
    func decode<D: Decodable>(from decoder: URLQueryItemsDecoder = URLQueryItemsDecoder()) throws -> D {
        return try D.decode(from: self, using: decoder)
    }
}
