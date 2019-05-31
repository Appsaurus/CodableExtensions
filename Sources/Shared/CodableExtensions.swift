//
//  CodableExtensions.swift
//  Pods
//
//  Created by Brian Strobach on 11/21/17.
//

import Foundation
import Codability

//MARK: Typealiases
public typealias AnyCodableDictionary = [String : AnyCodable]
public typealias AnyDictionary = [String : Any]

extension Encodable where Self: Decodable{
    //Simple method to copy any Codable object via encoding/decoding. Warning - will have higher overhead compared to something like NSCoding.
    public func copyCodable(encoder: JSONEncoder = .default, decoder: JSONDecoder = .default) throws -> Self{
        return try Self.decode(fromJSON: encodeAsJSONData(using: encoder), using: decoder)
    }
}
extension Encodable {
    public func encodeAsJSONData(using encoder: JSONEncoder = .default) throws -> Data {
        return try encoder.encode(self)
    }

    //WARN: There is some precision lost on decimals: https://bugs.swift.org/browse/SR-7054
    public func encodeAsJSONString(encoder: JSONEncoder = .default, stringEncoding: String.Encoding = .utf8) throws -> String{
        let jsonData = try encodeAsJSONData(using: encoder)
        guard let jsonString = String(data: jsonData, encoding: stringEncoding) else{
            let context = EncodingError.Context(codingPath: [], debugDescription: "Unable to convert data \(jsonData) from object \(self) to string.")
            throw EncodingError.invalidValue(self, context)
        }
        return jsonString
    }

    //Converts and encodable object -> JSON -> Dictionary.
    public func toAnyDictionary(encoder: JSONEncoder = .default, decoder: JSONDecoder = .default) throws -> AnyDictionary{
        return try encodeAsJSONData(using: encoder).decodeJSONAsDictionary(using: decoder)
    }
}

public extension EncodingError {
    static func dynamicEncodingError(invalidValue: Any) -> EncodingError {
        let contextDescription = "Attempted to encode an invalid value \(invalidValue)."
        let context = EncodingError.Context(codingPath: [], debugDescription: contextDescription)
        return EncodingError.invalidValue(invalidValue, context)
    }
}
extension Array {
    public func convertElementsToAnyDictionary(encoder: JSONEncoder = .default, decoder: JSONDecoder = .default) throws -> [Any]{
        var convertedArray: [Any] = []
        for element in self{
            guard let encodableElement = element as? Encodable else {
                throw EncodingError.dynamicEncodingError(invalidValue: element)
            }
            if !isCodableJSONPrimitive(element){
                convertedArray.append(try encodableElement.toAnyDictionary())
            }
            else{
                convertedArray.append(encodableElement)
            }
        }
        return convertedArray
    }
}


extension Encodable {

    /// Encodes object as JSON with the option of adding additional derived values at the callsite that are not automatically encoded by synthesized Codable implementation.
    ///
    /// - Parameters:
    ///   - derivedValues: Keyed values that are to be encoded alongside the automatically encoded values. These can be anything that is Encodable, a function that returns an encodable value, or a keypath of a computed encodable value.
    ///   - encoder: JSONEncoder to use when encoding object to json.
    ///   - decoder: JSONDecoder to use when main encodable object is first converted to AnyCodableDictionary.
    /// - Returns: JSON data.
    /// - Throws: EndcodingError if any of the derived values are not able to resovle an encodable value.
    public func encodeAsJSONData(including derivedValues: [String : Any],
                                 encoder: JSONEncoder = .default,
                                 decoder: JSONDecoder = .default) throws -> Data {
        var dictionary = try toAnyDictionary(encoder: encoder, decoder: decoder)
        let derivedValues = derivedValues
        for (key, value) in derivedValues{
            var dictionaryValue = value
            switch value{
            case let encodableFunction as () -> Any:
                dictionaryValue = encodableFunction()
            case let encodableKeyPath as PartialKeyPath<Self>:
                dictionaryValue = self[keyPath: encodableKeyPath]
            default: break
            }
            if !isCodableJSONPrimitive(dictionaryValue){
                switch dictionaryValue{
                case let arrayValue as Array<Encodable>:
                    dictionaryValue = try arrayValue.convertElementsToAnyDictionary(encoder: encoder, decoder: decoder)
                case let encodableValue as Encodable:
                    dictionaryValue = try encodableValue.toAnyDictionary()
                default: break
                }
            }

            dictionary[key] = dictionaryValue
        }
        return try dictionary.encodeAsJSONData(using: encoder)
    }
}

extension Decodable {
    static public func decode(fromJSON data: Data, using decoder: JSONDecoder = .default) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }

    static public func decode(fromJSON string: String, using decoder: JSONDecoder = .default) throws -> Self {
        return try decoder.decode(Self.self, from: try string.encodeAsJSONData())
    }
}


extension Data{
    public func decodeJSONAsDictionary(using decoder: JSONDecoder = .default, decodeNestedObjectsAsDictionaries: Bool = true) throws -> AnyDictionary {
        let decodableDictionary: AnyCodableDictionary = try decoder.decode(AnyCodableDictionary.self, from: self)
        let unwrappedDictionary = decodableDictionary.anyCodableUnwrapped()
        return unwrappedDictionary
    }

    public func decodeJSONAsArrayOfDictionaries(using decoder: JSONDecoder = .default) throws -> [AnyDictionary] {
        let decodableDictionary: [AnyCodableDictionary] = try decoder.decode([AnyCodableDictionary].self, from: self)
        return decodableDictionary.map({$0.anyCodableUnwrapped()})
    }

    public func decodeJSON<D: Decodable>(as type: D.Type = D.self, using decoder: JSONDecoder = .default) throws -> D{
        return try type.decode(fromJSON: self, using: decoder)
    }
}

extension String{

    public func deserializeJSONAsObject(stringEncoding: Encoding = .utf8, options: JSONSerialization.ReadingOptions = []) throws -> Any{
        guard let data = data(using: stringEncoding) else{
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unable to convert String to using \(stringEncoding) encoding."))
        }
        return try JSONSerialization.jsonObject(with: data, options: options)
    }

    public func deserializeJSONAsDictionary(stringEncoding: Encoding = .utf8, options: JSONSerialization.ReadingOptions = []) throws -> AnyDictionary {
        let jsonObject = try deserializeJSONAsObject(stringEncoding: stringEncoding, options: options)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unable to convert String to [AnyDictionaries]. Expected dictionary got \(jsonObject)."))
        }
        return dictionary
    }

    public func deserializeJSONAsArrayOfDictionaries(stringEncoding: Encoding = .utf8, options: JSONSerialization.ReadingOptions = []) throws -> [AnyDictionary] {
        let jsonObject = try deserializeJSONAsObject(stringEncoding: stringEncoding, options: options)
        guard let array = jsonObject as? [Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unable to convert String to [AnyDictionaries]. Expected JSON array got \(jsonObject)."))
        }
        return array.map { $0 as! [String: Any] }
    }

    public func deserializeJSONAsArrayOfAnyCodableDictionaries() throws -> [AnyCodableDictionary]{
        return try deserializeJSONAsArrayOfDictionaries().map({try $0.toAnyCodableDictionary()})
    }


}

extension Dictionary where Key == String, Value: Any {

    public func encodeAsJSONData(using encoder: JSONEncoder = .default) throws -> Data {
        let anyCodableDictionary: AnyCodableDictionary = try self.toAnyCodableDictionary()
        return try encoder.encode(anyCodableDictionary)
    }
}

extension Dictionary{
    public func serializeAsJSONData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: options)
    }

    public func serializeAsJSONString(options: JSONSerialization.WritingOptions = []) throws -> String? {
        let data: Data = try JSONSerialization.data(withJSONObject: self, options: options)
        return String(data: data, encoding: .utf8)
    }

    public func prettyJSONString() throws -> String?{
        return try serializeAsJSONString(options: .prettyPrinted)
    }
    public func printPrettyJSONString() throws{
        print(try serializeAsJSONString(options: .prettyPrinted) ?? "Pretty print serialization failed")
    }

}

private func isCodableJSONPrimitive(_ value: Any) -> Bool {
    switch value {
    case is Void,
         is Bool,
         is Int,
         is Int8,
         is Int16,
         is Int32,
         is Int64,
         is UInt,
         is UInt8,
         is UInt16,
         is UInt32,
         is UInt64,
         is Float,
         is Double,
         is String:
        return true
    default:
        return false
    }
}
