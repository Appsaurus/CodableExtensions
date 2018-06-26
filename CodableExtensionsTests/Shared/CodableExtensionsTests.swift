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
		("testDerivedValueEncoding", testDerivedValueEncoding)
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
		let original: TestModel = .init()
		var updated: TestModel = .init()
		XCTAssertJSONEqual(source: original, candidates: updated)
		try updated.update(with: encodedTestDictionary)
		XCTAssertJSONNotEqual(source: original, candidates: updated)
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

		let data = try model.encodeAsJSONData(including: derivedValues)

		let decodedModelDictionary: AnyDictionary = try data.decodeJSONAsDictionary()

		XCTAssertEqual(decodedModelDictionary[functionDerivedValueKey] as? String, model.functionDerivedValue())
		//TODO: Test other values
	}

}

public func XCTAssertJSONEqual(source: Encodable, candidates: Encodable...) {
	let sourceString = try! source.encodeAsJSONString()
	for candidate in candidates{
		XCTAssertEqual(sourceString, try! candidate.encodeAsJSONString())
	}
}

public func XCTAssertJSONNotEqual(source: Encodable, candidates: Encodable...){
	let sourceString = try! source.encodeAsJSONString()
	for candidate in candidates{
		XCTAssertNotEqual(sourceString, try! candidate.encodeAsJSONString())
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

open class TestModel: Codable{
	public var stringValue: String = ""
	public var optionalStringValue: String?
	public var intValue: Int = 0
	public var doubleValue: Double = 0.0
	public var booleanValue: Bool = false
	public var dateValue: Date = Date.init(timeIntervalSince1970: 1000)
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

	public required init(){}
}

open class NestedTestModel: Codable{
	public var stringValue: String = ""
	public var optionalStringValue: String?
	public var intValue: Int = 0
	public var doubleValue: Double = 0.0
	public var booleanValue: Bool = false
	public var dateValue: Date = Date()

	public required init(){}
}

#if !os(Linux)
extension CLLocationCoordinate2D: ReflectionCodable{

	public init(from decoder: Decoder) throws {
		self.init()
		try decodeReflectively(from: decoder)
	}
}
#endif
