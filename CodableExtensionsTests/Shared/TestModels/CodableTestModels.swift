//
//  CodableTestModels.swift
//  CodableExtensionsTests
//
//  Created by Brian Strobach on 4/30/19.
//

import Foundation
import CodableExtensions
import RuntimeExtensions
import Codability
#if !os(Linux)
import CoreLocation
#endif

let dateConstant = Date.init(timeIntervalSince1970: 1000)
public class TestModel: Codable {
    public var stringValue: String = ""
    public var optionalStringValue: String?
    public var intValue: Int = 0
    public var doubleValue: Double = 0.0
    public var booleanValue: Bool = false
    public var dateValue: Date = dateConstant
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

public class ExtendedTestModel: Codable {
    public var stringValue: String = ""
    public var optionalStringValue: String?
    public var intValue: Int = 0
    public var doubleValue: Double = 0.0
    public var booleanValue: Bool = false
    public var dateValue: Date = dateConstant
    public var storedNestedModel: NestedTestModel
    public var storedNestedModelCollection: [NestedTestModel]
    public var computedValueKey: String
    public var computedNestedModelKey: NestedTestModel
    public var computedNestedModelCollectionKey: [NestedTestModel]
    public var keyPathDerivedValueKey: String
    public var keyPathDerivedNestedModelKey: NestedTestModel
    public var keyPathDerivedNestedModelCollectionKey: [NestedTestModel]
    public var functionDerivedValueKey: String
    public var functionDerivedNestedModelKey: NestedTestModel
    public var functionDerivedNestedModelCollectionKey: [NestedTestModel]
    public var callsiteInstantiatedStringsKey: [String]
    public var callsiteInstantiatedModelKey: NestedTestModel
    public var callsiteInstantiatedModelCollectionKey: [NestedTestModel]
}

public struct NestedTestModel: Codable, Equatable {
    public var stringValue: String = ""
    public var optionalStringValue: String?
    public var intValue: Int = 0
    public var doubleValue: Double = 0.0
    public var booleanValue: Bool = false
    //    public var dateValue: Date = originalDate
}

#if !os(Linux)
extension CLLocationCoordinate2D: ReflectionCodable{

    public init(from decoder: Decoder) throws {
        self.init()
        try decodeReflectively(from: decoder)
    }
}
#endif
