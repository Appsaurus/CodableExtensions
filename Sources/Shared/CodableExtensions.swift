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
	public func copyCodable() throws -> Self{
		return try Self.decode(fromJSON: encodeAsJSONData(using: JSONEncoder()), using: JSONDecoder())
	}
}
extension Encodable {
	public func encodeAsJSONData(using encoder: JSONEncoder = .defaultEncoder) throws -> Data {
		return try encoder.encode(self)
	}

	//WARN: There is some precision lost on decimals: https://bugs.swift.org/browse/SR-7054
	public func encodeAsJSONString(using encoder: JSONEncoder = .defaultEncoder, stringEncoding: String.Encoding = .utf8) throws -> String{
		let jsonData = try encodeAsJSONData(using: encoder)
		guard let jsonString = String(data: jsonData, encoding: stringEncoding) else{
			let context = EncodingError.Context(codingPath: [], debugDescription: "Unable to convert data \(jsonData) from object \(self) to string.")
			throw EncodingError.invalidValue(self, context)
		}
		return jsonString
	}

	//Converts and encodable object -> JSON -> Dictionary.
	public func toAnyDictionary(using encoder: JSONEncoder = .defaultEncoder, decoder: JSONDecoder = .defaultDecoder) throws -> AnyDictionary{
		return try encodeAsJSONData(using: encoder).decodeJSONAsDictionary(using: decoder)
	}
}

extension Array where Element: AnyObject{
	public func convertElementsToAnyDictionary(using encoder: JSONEncoder = .defaultEncoder, decoder: JSONDecoder = .defaultDecoder) throws -> [Any]{
			var convertedArray: [Any] = []
			for element in self{
				if let encodableElement = element as? Encodable{
					convertedArray.append(try encodableElement.toAnyDictionary())
				}
				else{
					convertedArray.append(element)
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
								 using encoder: JSONEncoder = .defaultEncoder,
								 using decoder: JSONDecoder = .defaultDecoder) throws -> Data {
		var dictionary = try toAnyCodableDictionary(using: encoder, using: decoder)
		let derivedValues = derivedValues
		for (key, value) in derivedValues{
			var value = value
			switch value{
			case let encodableFunction as () -> Any:
				value = encodableFunction()
			case let encodableKeyPath as PartialKeyPath<Self>:
				value = self[keyPath: encodableKeyPath]
			default: break
			}

			switch value{
			case let arrayValue as Array<AnyObject>:
				//Convert arrays of encodable objects to dictionary representations
				value = try arrayValue.convertElementsToAnyDictionary(using: encoder, decoder: decoder)
			case let encodableValue as AnyObject & Encodable:
				value = try encodableValue.toAnyDictionary()
			default: break
			}
			dictionary[key] = AnyCodable.wrap(value)
		}
		return try dictionary.encodeAsJSONData(using: encoder)
	}
}

extension Decodable {
	static public func decode(fromJSON data: Data, using decoder: JSONDecoder = .defaultDecoder) throws -> Self {
		return try decoder.decode(Self.self, from: data)
	}

	static public func decode(fromJSON string: String, using decoder: JSONDecoder = .defaultDecoder) throws -> Self {
		return try decoder.decode(Self.self, from: try string.encodeAsJSONData())
	}
}

extension Data{
	public func decodeJSONAsDictionary(using decoder: JSONDecoder = .defaultDecoder, decodeNestedObjectsAsDictionaries: Bool = true) throws -> AnyDictionary {
		let decodableDictionary: AnyCodableDictionary = try decoder.decode(AnyCodableDictionary.self, from: self)
		let unwrappedDictionary = decodableDictionary.anyCodableUnwrapped()
		return unwrappedDictionary
	}

	public func decodeJSONAsArrayOfDictionaries(using decoder: JSONDecoder = .defaultDecoder) throws -> [AnyDictionary] {
		let decodableDictionary: [AnyCodableDictionary] = try decoder.decode([AnyCodableDictionary].self, from: self)
		return decodableDictionary.map({$0.anyCodableUnwrapped()})
	}

	public func decodeJSON<D: Decodable>(as type: D.Type = D.self, using decoder: JSONDecoder = .defaultDecoder) throws -> D{
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

	public func encodeAsJSONData(using encoder: JSONEncoder = .defaultEncoder) throws -> Data {
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

extension Encodable{
	public func jsonIsEqual(to candidates: [Encodable]) -> Bool{
		let sourceJson = try! encodeAsJSONData()
		return !candidates.contains(where: {try! $0.encodeAsJSONData() != sourceJson})
	}
}
