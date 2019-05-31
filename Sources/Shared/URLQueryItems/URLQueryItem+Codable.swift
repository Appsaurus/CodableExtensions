//
//  URLQueryItem+Codable.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/30/19.
//

import Foundation

extension URLQueryItem: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let value = try container.decode(String.self, forKey: .value)
        self.init(name: name, value: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

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
