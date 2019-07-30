//
//  URL+QueryItemsDecoding.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 6/5/19.
//

import Foundation

extension Decodable {
    static func decode(fromURL url: URL,  decoder: JSONDecoder) throws -> Self {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            throw URLQueryDecodingError.missingURLQueryItems
        }
        return try decode(fromQueryItems: queryItems)
    }
}

public enum URLQueryDecodingError: Error {
    case missingURLQueryItems
    case invalidQuery(Any.Type, String)
}

extension URLQueryDecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQuery(let type, let url):
            return "Could not decode \(type) from url \(url)"
        default: return "\(self)"
        }
    }
}

public extension Array where Element == URLQueryItem {
    var queryString: String {
        var output: String = ""
        for item in self {
            if let value = item.value {
                output += "\(item.name)=\(value)&"
            }
        }
        output = String(output.dropLast())
        return output.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}



