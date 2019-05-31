//
//  Storage.swift
//  CodableExtensions
//
//  Created by Brian Strobach on 5/30/19.
//

import Foundation

final class ContainerStorage {
    private(set) var containers: [Any] = []

    var count: Int {
        return containers.count
    }

    var last: Any? {
        return containers.last
    }

    func push(container: Any) {
        containers.append(container)
    }

    @discardableResult
    func popContainer() -> Any {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}

public enum URLQueryItemsCodingError: Error {
    case cast
    case unwrapped
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any, error: Error = URLQueryItemsCodingError.cast) throws -> T {
    guard let returnValue = object as? T else {
        throw error
    }

    return returnValue
}

extension Optional {
    func unwrapOrThrow(error: Error = URLQueryItemsCodingError.unwrapped) throws -> Wrapped {
        guard let unwrapped = self else {
            throw error
        }

        return unwrapped
    }
}
