//
//  Encodable+URLQueryItems.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 6/5/19.
//

import Foundation

public extension Encodable {
    func encodeAsURLQueryItems(using encoder: URLQueryItemEncoder = URLQueryItemEncoder()) throws -> [URLQueryItem] {
        return try encoder.encode(self)
    }
}
