//
//  CodableTransformer.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 11/30/18.
//

import Foundation
import Codability

public protocol EncodableTransformationProvider{
    func transformEncode(from encodableType: AnyCodable) throws -> AnyCodable
}

public protocol DecodableTransformationProvider{
    func transformDecode(from externalRepresentation: AnyCodable) throws -> AnyCodable
}

public protocol CodableTransformer: EncodableTransformationProvider, DecodableTransformationProvider{}


extension Encodable{
    public func toAnyCodableDictionary(using encoder: JSONEncoder = .default,
                                       using decoder: JSONDecoder = .default,
                                       withTransformers transformers: [String : CodableTransformer]) throws -> AnyCodableDictionary{
        var anyCodableDictionary = try self.toAnyCodableDictionary()
        for (key, transformer) in transformers{
            if let value = anyCodableDictionary[key]{
                anyCodableDictionary[key] = AnyCodable(try transformer.transformEncode(from: value))
            }            
        }
        return anyCodableDictionary
    }
    
    public func encode(using encoder: JSONEncoder = .default,
                                       using decoder: JSONDecoder = .default,
                                       withTransformers transformers: [String : CodableTransformer]) throws -> Data{
        return try toAnyCodableDictionary(using: encoder, using: decoder, withTransformers: transformers).encodeAsJSONData()
    }
}

public enum AnyCodableTransformationError: Error{
    case unexpectedTypeError(Any.Type, Any.Type)
}
