//
//  KeyedContainer.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 1/22/20.
//

import Foundation

// MARK: - KeyedContainer
/// A property wrapper for dictionaries with keys that are raw-representable as strings.
/// It modifies the wrapped dictionary's encoding/decoding behavior such that the dictionary
/// is encoded as a dictionary (unkeyed container) rather than as an array (keyed container).
///
    /// For context, see <https://oleb.net/blog/2017/12/dictionary-codable-array/>.
    @propertyWrapper
    public struct KeyedContainer<Key, Value> where Key: Hashable & RawRepresentable, Key.RawValue == String {
      public var wrappedValue: [Key: Value]

        public init(wrappedValue: [Key: Value]) {
            self.wrappedValue = wrappedValue
        }
      /// Copied from the standard library (`_DictionaryCodingKey`).
      private struct CodingKeys: CodingKey {
        let stringValue: String
        let intValue: Int?

        public init?(stringValue: String) {
          self.stringValue = stringValue
          self.intValue = Int(stringValue)
        }

        public init?(intValue: Int) {
          self.stringValue = "\(intValue)"
          self.intValue = intValue
        }
      }
    }

extension KeyedContainer: Equatable where Key: Equatable, Value: Equatable {}

extension KeyedContainer: Encodable where Key: Encodable, Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    for (key, value) in wrappedValue {
      let codingKey = CodingKeys(stringValue: key.rawValue)!
      try container.encode(value, forKey: codingKey)
    }
  }
}

extension KeyedContainer: Decodable where Key: Decodable, Value: Decodable {
  public init(from decoder: Decoder) throws {
    wrappedValue = [:]
    let container = try decoder.container(keyedBy: CodingKeys.self)
    for key in container.allKeys {
      let value = try container.decode(Value.self, forKey: key)
      wrappedValue[Key(rawValue: key.stringValue)!] = value
    }
  }
}
