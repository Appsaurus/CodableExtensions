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
import Codability
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
        ("testTransformers", testTransformers)
	]

	func testLinuxTestSuiteIncludesAllTests(){
		assertLinuxTestCoverage(tests: type(of: self).allTests)
	}
	lazy var testDictionary: AnyDictionary = {
		return ["stringValue" : "updatedStringValue",
				"optionalStringValue" : "updatedOptionalStringValue",
				"intValue" : 1,
				"doubleValue" : 3.1,
				"booleanValue" : true
		]
	}()

	lazy var encodedTestDictionary: Data = try! testDictionary.encodeAsJSONData()

	public func testDecodeDictionaryFromData() throws{
		let decodedDictionary: AnyDictionary = try encodedTestDictionary.decodeJSONAsDictionary()
		XCTAssertEqualPrimitiveValues(source: decodedDictionary, candidates: testDictionary.anyCodableUnwrapped())
	}

	public func testDecoderUpdatable() throws{
//        let original: TestModel = .init()
//        var updated: TestModel = .init()
//        XCTAssertJSONEqual(source: original, candidates: updated)
//        try updated.update(with: encodedTestDictionary)
//        XCTAssertJSONNotEqual(source: original, candidates: updated)
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
        let models = [NestedTestModel(), NestedTestModel()]
        let dict = try models.encodeAsJSONData()
        let decoded = try dict.decodeJSONAsArrayOfDictionaries()

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
        let functionDerivedNestedCollectionModelKey: String = "functionDerivedNestedCollectionModelKey"

        //Callsite instantiated

        let callsiteInstantiatedStringsKey = "callsiteInstantiatedStrings"
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
            functionDerivedNestedCollectionModelKey: model.functionDerivedNestedCollectionValue(),
            callsiteInstantiatedStringsKey: callsiteInstantiatedStrings,
            callsiteInstantiatedModelKey: callsiteInstantiatedModel,
            callsiteInstantiatedModelCollectionKey: callsiteInstantiatedModelCollection
        ]
//        let values: AnyCodableDictionary = try derivedValues.toAnyCodableDictionary()

        let data = try model.encodeAsJSONData(including: derivedValues)
//        let test = try callsiteInstantiatedModelCollection.encodeAsJSONData()
        let decodedModelDictionary: AnyDictionary = try data.decodeJSONAsDictionary()

        XCTAssertEqual(decodedModelDictionary[functionDerivedValueKey] as? String, model.functionDerivedValue())
        //TODO: Test other values
	}
    
    public func testTransformers() throws{
        
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

let originalDate = Date.init(timeIntervalSince1970: 1000)
public class TestModel: Codable {
	public var stringValue: String = ""
	public var optionalStringValue: String?
	public var intValue: Int = 0
	public var doubleValue: Double = 0.0
	public var booleanValue: Bool = false
	public var dateValue: Date = originalDate
	public var storedNestedModel: NestedTestModel = NestedTestModel()
	public var storedNestedModelCollection: [NestedTestModel] = [NestedTestModel(), NestedTestModel()]

	public var computedValue: String{
		return "derivedValue"
	}

	public var computedNestedModel: NestedTestModel{
		return NestedTestModel()
	}

	public var computedNestedModelCollection: [NestedTestModel]{
		return [NestedTestModel(), NestedTestModel()]
	}
	public func functionDerivedValue() -> String{
		return "functionDerivedValue"
	}
	public func functionDerivedNestedModel() -> NestedTestModel{
		return NestedTestModel()
	}
	public func functionDerivedNestedCollectionValue() -> [NestedTestModel]{
		return [NestedTestModel(), NestedTestModel()]
	}
}

public class NestedTestModel: Codable {
	public var stringValue: String = ""
	public var optionalStringValue: String?
	public var intValue: Int = 0
	public var doubleValue: Double = 0.0
	public var booleanValue: Bool = false
	public var dateValue: Date = originalDate
}

#if !os(Linux)
extension CLLocationCoordinate2D: ReflectionCodable{

	public init(from decoder: Decoder) throws {
		self.init()
		try decodeReflectively(from: decoder)
	}
}
#endif

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
