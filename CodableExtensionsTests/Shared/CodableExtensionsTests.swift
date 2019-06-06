//
//  CodableExtensionTests.swift
//  DinoDNA
//
//  Created by Brian Strobach on 4/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import SwiftTestUtils
import CodableExtensions
import RuntimeExtensions

#if !os(Linux)
import CoreLocation
#endif
class CodableExtensionsTests: BaseTestCase{

    //MARK: Linux Testing
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testDecodeDictionaryFromData", testDecodeDictionaryFromData),
        ("testDecoderUpdatable", testDecoderUpdatable),
        ("testReflectionCoding", testReflectionCoding),
        ("testDerivedValueEncoding", testDerivedValueEncoding),
        ("testTransformers", testTransformers),
        ("testDecodeSimpleParameter", testDecodeSimpleParameter),
        ("testDecodeOptionalParameter", testDecodeOptionalParameter),
        ("testDecodeEmptyOptionalParameter", testDecodeEmptyOptionalParameter),
        ("testEncodeSimpleParameter", testEncodeSimpleParameter)
    ]

    func testLinuxTestSuiteIncludesAllTests(){
        assertLinuxTestCoverage(tests: type(of: self).allTests)
    }
    lazy var primitiveDictionary: AnyDictionary = {
        return ["stringValue" : "updatedStringValue",
                "optionalStringValue" : "updatedOptionalStringValue",
                "intValue" : 1,
                "doubleValue" : 3.1,
                "booleanValue" : true
        ]
    }()

    lazy var encodedTestDictionary: Data = try! primitiveDictionary.encodeAsJSONData()

    public func testDecodeDictionaryFromData() throws{
        let decodedDictionary: AnyDictionary = try encodedTestDictionary.decodeJSONAsDictionary()
        XCTAssertEqualPrimitiveValues(source: decodedDictionary, candidates: primitiveDictionary)
    }

    public func testDecoderUpdatable() throws{
        let original: TestModel = .init()
        var updated: TestModel = .init()

        XCTAssertEqual(original.stringValue, updated.stringValue)
        XCTAssertEqual(original.optionalStringValue, updated.optionalStringValue)
        XCTAssertEqual(original.intValue, updated.intValue)
        XCTAssertEqual(original.doubleValue, updated.doubleValue)
        XCTAssertEqual(original.booleanValue, updated.booleanValue)

        try updated.update(with: encodedTestDictionary)

        XCTAssertNotEqual(original.stringValue, updated.stringValue)
        XCTAssertNotEqual(original.optionalStringValue, updated.optionalStringValue)
        XCTAssertNotEqual(original.intValue, updated.intValue)
        XCTAssertNotEqual(original.doubleValue, updated.doubleValue)
        XCTAssertNotEqual(original.booleanValue, updated.booleanValue)

        XCTAssertEqual(primitiveDictionary["stringValue"] as! String, updated.stringValue)
        XCTAssertEqual(primitiveDictionary["optionalStringValue"] as! String?, updated.optionalStringValue)
        XCTAssertEqual(primitiveDictionary["intValue"] as! Int, updated.intValue)
        XCTAssertEqual(primitiveDictionary["doubleValue"] as! Double, updated.doubleValue)
        XCTAssertEqual(primitiveDictionary["booleanValue"] as! Bool, updated.booleanValue)

    }

    public func testReflectionCoding() throws{
        #if !os(Linux)
        let coordinate = CLLocationCoordinate2D(latitude: 25.0000, longitude: 71.0000)
        let encodedCoordinate = try coordinate.encodeAsJSONData()
        let decodedCoordinate: CLLocationCoordinate2D = try encodedCoordinate.decodeJSON()
        XCTAssertEqual(coordinate.latitude, decodedCoordinate.latitude)
        XCTAssertEqual(coordinate.longitude, decodedCoordinate.longitude)
        #endif
    }

    public func testDerivedValueEncoding() throws{
        let model = TestModel()
        let computedValueKey: String = "computedValueKey"
        let computedNestedModelKey: String = "computedNestedModelKey"
        let computedNestedModelCollectionKey: String = "computedNestedModelCollectionKey"

        //Derived from models keypaths
        let keyPathDerivedValueKey: String = "keyPathDerivedValueKey"
        let keyPathDerivedNestedModelKey: String = "keyPathDerivedNestedModelKey"
        let keyPathDerivedNestedModelCollectionKey: String = "keyPathDerivedNestedModelCollectionKey"

        //Derived from model functions
        let functionDerivedValueKey: String = "functionDerivedValueKey"
        let functionDerivedNestedModelKey: String = "functionDerivedNestedModelKey"
        let functionDerivedNestedModelCollectionKey: String = "functionDerivedNestedModelCollectionKey"

        //Callsite instantiated

        let callsiteInstantiatedStringsKey = "callsiteInstantiatedStringsKey"
        let callsiteInstantiatedStrings = ["derived", "derived", "derived"]

        let callsiteInstantiatedModelKey: String = "callsiteInstantiatedModelKey"
        let callsiteInstantiatedModel = NestedTestModel()

        let callsiteInstantiatedModelCollectionKey: String = "callsiteInstantiatedModelCollectionKey"
        let callsiteInstantiatedModelCollection = [NestedTestModel(), NestedTestModel()]

        let derivedValues: [String : Any] = [
            computedValueKey : model.computedValue,
            computedNestedModelKey: model.computedNestedModel,
            computedNestedModelCollectionKey: model.computedNestedModelCollection,
            keyPathDerivedValueKey : \TestModel.computedValue,
            keyPathDerivedNestedModelKey: \TestModel.computedNestedModel,
            keyPathDerivedNestedModelCollectionKey: \TestModel.computedNestedModelCollection,
            functionDerivedValueKey: model.functionDerivedValue(),
            functionDerivedNestedModelKey: model.functionDerivedNestedModel(),
            functionDerivedNestedModelCollectionKey: model.functionDerivedNestedCollectionValue(),
            callsiteInstantiatedStringsKey: callsiteInstantiatedStrings,
            callsiteInstantiatedModelKey: callsiteInstantiatedModel,
            callsiteInstantiatedModelCollectionKey: callsiteInstantiatedModelCollection
        ]

        let data = try model.encodeAsJSONData(including: derivedValues)
        let extendedTestModel = try ExtendedTestModel.decode(fromJSON: data)


        XCTAssertEqual(extendedTestModel.stringValue, model.stringValue)
        XCTAssertEqual(extendedTestModel.optionalStringValue, model.optionalStringValue)
        XCTAssertEqual(extendedTestModel.intValue, model.intValue)
        XCTAssertEqual(extendedTestModel.doubleValue, model.doubleValue)
        XCTAssertEqual(extendedTestModel.booleanValue, model.booleanValue)
        XCTAssertEqual(extendedTestModel.dateValue, model.dateValue)
        XCTAssertEqual(extendedTestModel.storedNestedModel, model.storedNestedModel)
        XCTAssertEqual(extendedTestModel.storedNestedModelCollection, model.storedNestedModelCollection)
        XCTAssertEqual(extendedTestModel.computedValueKey, model.computedValue)
        XCTAssertEqual(extendedTestModel.computedNestedModelKey, model.computedNestedModel)
        XCTAssertEqual(extendedTestModel.computedNestedModelCollectionKey, model.computedNestedModelCollection)
        XCTAssertEqual(extendedTestModel.keyPathDerivedValueKey, model.computedValue)
        XCTAssertEqual(extendedTestModel.keyPathDerivedNestedModelKey, model.computedNestedModel)
        XCTAssertEqual(extendedTestModel.keyPathDerivedNestedModelCollectionKey, model.computedNestedModelCollection)
        XCTAssertEqual(extendedTestModel.functionDerivedValueKey, model.functionDerivedValue())
        XCTAssertEqual(extendedTestModel.functionDerivedNestedModelKey, model.functionDerivedNestedModel())
        XCTAssertEqual(extendedTestModel.functionDerivedNestedModelCollectionKey, model.functionDerivedNestedCollectionValue())
        XCTAssertEqual(extendedTestModel.callsiteInstantiatedStringsKey, callsiteInstantiatedStrings)
        XCTAssertEqual(extendedTestModel.callsiteInstantiatedModelKey, callsiteInstantiatedModel)
        XCTAssertEqual(extendedTestModel.callsiteInstantiatedModelCollectionKey, callsiteInstantiatedModelCollection)


        //        let decodedModelDictionary: AnyDictionary = try data.decodeJSONAsDictionary()
        //        XCTAssertEqual(decodedModelDictionary[computedValueKey] as! String, model.computedValue)
        //        XCTAssertEqual(decodedModelDictionary[computedNestedModelKey] as! NestedTestModel, model.computedNestedModel)
        //        XCTAssertEqual(decodedModelDictionary[computedNestedModelCollectionKey] as! [NestedTestModel], model.computedNestedModelCollection)
        //        XCTAssertEqual(decodedModelDictionary[keyPathDerivedValueKey] as! String,  model.computedValue)
        //        XCTAssertEqual(decodedModelDictionary[keyPathDerivedNestedModelKey] as! NestedTestModel, model.computedNestedModel)
        //        XCTAssertEqual(decodedModelDictionary[keyPathDerivedNestedModelCollectionKey] as! [NestedTestModel], model.computedNestedModelCollection)
        //        XCTAssertEqual(decodedModelDictionary[functionDerivedValueKey] as! String , model.functionDerivedValue())
        //        XCTAssertEqual(decodedModelDictionary[functionDerivedNestedModelKey] as! NestedTestModel, model.functionDerivedNestedModel())
        //        XCTAssertEqual(decodedModelDictionary[functionDerivedNestedModelCollectionKey] as! [NestedTestModel], model.functionDerivedNestedCollectionValue())
        //        XCTAssertEqual(decodedModelDictionary[callsiteInstantiatedStringsKey] as! [String], callsiteInstantiatedStrings)
        //        XCTAssertEqual(decodedModelDictionary[callsiteInstantiatedModelKey] as! NestedTestModel , callsiteInstantiatedModel)
        //        XCTAssertEqual(decodedModelDictionary[callsiteInstantiatedModelCollectionKey] as! [NestedTestModel], callsiteInstantiatedModelCollection)

    }

    public func testTransformers() throws{

    }

    func testDecodeSimpleParameter() throws {
        struct Parameter: Codable {
            let string: String
            let int: Int
            let double: Double
            let date: Date
        }
        let stringValue = "string"
        let intValue = 123
        let doubleValue = Double.pi
        let date = Date()

        let parameter = Parameter(string: stringValue, int: intValue, double: doubleValue, date: date)
        let queryItems: [URLQueryItem] = try parameter.encodeAsURLQueryItems()

        let parameterDecoded = try Parameter.decode(fromQueryItems: queryItems)

        XCTAssertEqual(parameterDecoded.string, parameter.string)
        XCTAssertEqual(parameterDecoded.int, parameter.int)
        XCTAssertEqual(parameterDecoded.double, parameter.double)
        XCTAssertEqual(parameterDecoded.date.description, parameter.date.description)

    }

    func testDecodeOptionalParameter() throws {
        struct Parameter: Codable {
            let string: String?
            let int: Int?
            let double: Double?
        }

        let stringValue = "string"
        let doubleValue = Double.pi
        let parameter = Parameter(string: stringValue, int: nil, double: doubleValue)
        let params: [URLQueryItem] = try parameter.encodeAsURLQueryItems()
        let parameterDecoded = try Parameter.decode(fromQueryItems: params)

        XCTAssertEqual(parameterDecoded.string, parameter.string)
        XCTAssertEqual(parameterDecoded.int, parameter.int)
        XCTAssertEqual(parameterDecoded.double, parameter.double)
    }

    func testDecodeEmptyOptionalParameter() throws {
        struct Parameter: Codable {
            let string: String?
            let int: Int?
            let double: Double?
        }
         let parameter = try Parameter.decode(fromQueryItems: [])

        XCTAssertEqual(parameter.string, nil)
        XCTAssertEqual(parameter.int, nil)
        XCTAssertEqual(parameter.double, nil)
    }

    func testEncodeSimpleParameter() throws {
        struct Parameter: Codable {
            let query: String
            let offset: Int
            let limit: Int
        }
        let parameter = Parameter(query: "ねこ", offset: 10, limit: 20)
        let params: [URLQueryItem] = try parameter.encodeAsURLQueryItems()
        XCTAssertEqual("query", params[0].name)
        XCTAssertEqual(parameter.query, params[0].value)
        XCTAssertEqual("offset", params[1].name)
        XCTAssertEqual(parameter.offset.description, params[1].value)
        XCTAssertEqual("limit", params[2].name)
        XCTAssertEqual(parameter.limit.description, params[2].value)

        var components = URLComponents(string: "https://example.com")
        components?.queryItems = params
        XCTAssertEqual(components?.url?.absoluteString, "https://example.com?query=%E3%81%AD%E3%81%93&offset=10&limit=20")
    }

}

extension Encodable{
    public func jsonIsEqual(to candidates: [Encodable]) -> Bool{
        let sourceJson = try! encodeAsJSONData()
        return !candidates.contains(where: {try! $0.encodeAsJSONData() != sourceJson})
    }
}
public func XCTAssertJSONEqual(source: Encodable, candidates: Encodable...) {
    let sourceString = try! source.encodeAsJSONString()
    for candidate in candidates{
        XCTAssertEqual(sourceString, try! candidate.encodeAsJSONString())
    }
}

public func XCTAssertJSONNotEqual(source: Encodable, candidates: Encodable...){
    let sourceString = try! source.encodeAsJSONData()
    for candidate in candidates{
        XCTAssertNotEqual(sourceString, try! candidate.encodeAsJSONData())
    }
}

public func XCTAssertEqualPrimitiveValues(source: Any?, candidates: Any?...){
    for candidate in candidates{
        XCTAssert(areEqualPrimitiveValues(source, candidate))
    }
}

func areEqualPrimitiveValues(_ lhs: Any?, _ rhs: Any?) -> Bool{
    guard let a = lhs, let b = rhs else{
        return lhs == nil && rhs == nil
    }
    switch (a, b) {
    case let (aVal as Bool, bVal as Bool):
        return aVal == bVal
    case let (aVal as Date, bVal as Date):
        return aVal == bVal
    case let (aVal as Int, bVal as Int):
        return aVal == bVal
    case let (aVal as Double, bVal as Double):
        return aVal == bVal
    case let (aVal as String, bVal as String):
        return aVal == bVal
    case let (aVal as AnyDictionary, bVal as AnyDictionary):
        var equal = true
        for (key, value) in aVal{
            equal = areEqualPrimitiveValues(value, bVal[key])
            if !equal{
                return false
            }
        }
        return true
    default:
        return false
    }
}



//
//@available(OSX 10.13, *)
//class ISO8601_to_RFC3339StringTransformer: CodableTransformer{
//    
//    lazy var RFC3339DateFormatter: DateFormatter = {
//        let RFC3339DateFormatter = DateFormatter()
//        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//        return RFC3339DateFormatter
//    }()
//    
//    let iso8601DateFormatter: ISO8601DateFormatter = .iso8601
//    
//    public func transformEncode(from encodableType: AnyCodable) throws -> AnyCodable {
//        guard let date = encodableType.value as? Date else {
//            throw AnyCodableTransformationError.unexpectedTypeError(type(of: encodableType.value), Date.self)
//        }
//        
//        return AnyCodable(DateFormatter().string(from: date))
//        
//    }
//    
//    public func transformDecode(from externalRepresentation: AnyCodable) throws -> AnyCodable {
//        guard let string = externalRepresentation.value as? String else {
//            throw AnyCodableTransformationError.unexpectedTypeError(type(of: encodableType.value), String.self)
//        }
//        
//        let rfcDate = RFC3339DateFormatter.date(from: string)
//        return AnyCodable(iso8601DateFormatter.date(from: rfcDate?.string_iso8601))
//    }
//    
//}
