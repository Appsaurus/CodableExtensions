//
//  Decodable+URLQueryItems.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/30/19.
//

import Foundation
import RuntimeExtensions

extension Decodable {

    /// Decodes a decodable object from URLQueryItem array. This first encodes the string values into a JSONEncoder. This currently only works with simple, primitive properties.
    ///
    /// - Parameters:
    ///   - queryItems: URLQueryItems to decode from
    ///   - decoder: decoder used to decode from URLQueryItems
    ///   - encoder: encoder used to encode the URLQueryItem string values into JSON data before decoding
    /// - Returns: Decoded object
    /// - Throws: Standard encoding/decoding errors
    public static func decode(fromQueryItems queryItems: [URLQueryItem],
                              decoder: JSONDecoder = .default,
                              encoder: JSONEncoder = .default) throws -> Self {
        var queryDict = queryItems.dictionary
        var dict: [String : Any] = [:]
        for prop in try properties(self) {
            guard let stringValue = queryDict[prop.name] else { continue }
            switch prop.type {
            case is Bool.Type, is Optional<Bool>.Type:
                dict[prop.name] = Bool(stringValue)
            case is Int.Type, is Optional<Int>.Type:
                dict[prop.name] = Int(stringValue)
            case is Int8.Type, is Optional<Int8>.Type:
                dict[prop.name] = Int8(stringValue)
            case is Int16.Type, is Optional<Int16>.Type:
                dict[prop.name] = Int16(stringValue)
            case is Int32.Type, is Optional<Int32>.Type:
                dict[prop.name] = Int32(stringValue)
            case is Int64.Type, is Optional<Int64>.Type:
                dict[prop.name] = Int64(stringValue)
            case is UInt.Type, is Optional<UInt>.Type:
                dict[prop.name] = UInt(stringValue)
            case is UInt8.Type, is Optional<UInt8>.Type:
                dict[prop.name] = UInt8(stringValue)
            case is UInt16.Type, is Optional<UInt16>.Type:
                dict[prop.name] = UInt16(stringValue)
            case is UInt32.Type, is Optional<UInt32>.Type:
                dict[prop.name] = UInt32(stringValue)
            case is UInt64.Type, is Optional<UInt64>.Type:
                dict[prop.name] = UInt64(stringValue)
            case is Float.Type, is Optional<Float>.Type:
                dict[prop.name] = Float(stringValue)
            case is Double.Type, is Optional<Double>.Type:
                dict[prop.name] = Double(stringValue)
            case is String.Type, is Optional<String>.Type:
                dict[prop.name] = stringValue
            case is Date.Type, is Optional<Date>.Type:
                dict[prop.name] = ISO8601DateFormatter().date(from: stringValue)!
            default: dict[prop.name] = stringValue
            }
        }
        return try decode(fromJSON: try dict.encodeAsJSONData(using: encoder), using: decoder)
    }
}

private extension Array where Element == URLQueryItem {
    var dictionary: [String: String] {
        var urlParams: [String: String] = [:]
        for param in self {
            if let value = param.value {
                urlParams[param.name] = value
            }
        }
        return urlParams
    }
}
