//
//  Codable+iso8601.swift
//  Pods
//
//  Created by Brian Strobach on 4/9/18.
//

import Foundation

@available(iOS 10.0, *)
@available(watchOSApplicationExtension 4.0, *)
@available(OSX 10.13, *)
extension Formatter {

	static public let iso8601: ISO8601DateFormatter = {
		let formatter = ISO8601DateFormatter()
		#if !os(Linux)
		if #available(iOS 11.0, *) {
			formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		} else {
			formatter.formatOptions = [.withInternetDateTime]
		}
		#else
		formatter.formatOptions = [.withInternetDateTime]
		#endif
		return formatter
	}()
}


extension Formatter {
	static public let iso8601_noFractionalSeconds: DateFormatter = {
		let formatter = DateFormatter()
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
		return formatter
	}()
}

extension Date {
	public var string_iso8601: String {

		if #available(OSX 10.13, watchOSApplicationExtension 4.0, iOS 10.0, *){
			return Formatter.iso8601.string(from: self)
		} else {
			return Formatter.iso8601_noFractionalSeconds.string(from: self)
		}
	}
}


extension String {
	public var date_iso8601: Date? {
		if #available(OSX 10.13, watchOSApplicationExtension 4.0, iOS 10.0, *){
			return Formatter.iso8601.date(from: self)!
		}
		else {
			return Formatter.iso8601_noFractionalSeconds.date(from: self)!
		}
	}
}

extension JSONEncoder.DateEncodingStrategy {
	static public let custom_iso8601 = custom { date, encoder throws in
		var container = encoder.singleValueContainer()
		try container.encode(date.string_iso8601)
	}
}


extension JSONDecoder.DateDecodingStrategy {
	static public let custom_iso8601 = custom { decoder throws -> Date in
		let container = try decoder.singleValueContainer()
		let string = try container.decode(String.self)
		if let date = string.date_iso8601 {
			return date
		}
		throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
	}
}
