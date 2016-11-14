//
//  DataMapper.swift
//  SimpleNetworking
//
//  Created by Downey, Eric on 10/20/16.
//  Copyright © 2016 Eric Downey. All rights reserved.
//

import Foundation

public protocol Mappable {
    init?(mapper: Mapper)
}

public enum MapperError: Error {
    case StringCoerceError(String)
    case DoubleCoerceError(String)
    case IntCoerceError(String)
    case FloatCoerceError(String)
    case DateCoerceError(String)
    case BoolCoerceError(String)
    case CustomTypeCoerceError(String)
}

public struct Mapper {
    
    var value: Any?
    fileprivate var valueObject: AnyObject? {
        return value as? AnyObject
    }
    private var dateFormats: [String]
    
    public init(value: Any?) {
        self.value = value
        self.dateFormats = []
    }
    
    public init(value: AnyObject?) {
        self.value = value
        self.dateFormats = []
    }
    
    public init(value: AnyObject?, dateFormats: [String]) {
        self.value = value
        self.dateFormats = dateFormats
    }
    
    public init(value: AnyObject?, dateFormats: String...) {
        self.value = value
        self.dateFormats = dateFormats
    }
    
    /// Registers a custom date format to be used when attempting to parse date objects
    public mutating func register(dateFormats formats: String) {
        dateFormats.append(formats)
    }
    
    // MARK: - Subscripts
    
    /// A subscript for retrieving values from a string key
    public subscript(_ key: String) -> Mapper {
        return Mapper(value: valueObject?[key] as AnyObject?)
    }
    
    /// A subscript for retrieving values from a number key
    public subscript(_ key: NSNumber) -> Mapper {
        let v = valueObject?[key] as AnyObject?
        return Mapper(value: v)
    }
    
    /// A subscript for retrieving values from an object key
    public subscript(_ key: NSObject) -> Mapper {
        let v = (self.value as? Dictionary<NSObject, AnyObject>)?[key]
        return Mapper(value: v)
    }
    
    /// Converts value to 'NSDictionary' and retrives a value by keypath and returns a new Mapper object
    public subscript(keypath path: String) -> Mapper {
        let v = valueObject?.value(forKeyPath: path)
        return Mapper(value: v)
    }
    
    // MARK: - Typed Values
    
    /// Attempts to coerce an optional string value
    public var string: String? {
        if let s = self.value as? String { return s }
        if let v = self.value { return "\(v)" }
        return nil
    }
    
    /// Attempts to coerce an optional double value
    public var double: Double? {
        if let v = self.value as? String { return Double(v) }
        return self.value as? Double
    }
    
    /// Attempts to coerce an optional int value
    public var int: Int? {
        if let v = self.value as? String { return Int(v) }
        return self.value as? Int
    }
    
    /// Attempts to coerce an optional float value
    public var float: Float? {
        if let v = self.value as? String { return Float(v) }
        return self.value as? Float
    }
    
    /// Attempts to coerce an optional date value
    public var date: Date? {
        if let v = self.value as? String {
            if let date = self.attemptDateTypes(onValue: v) { return date }
            if let date = get(dateString: v, from: .full) { return date }
            if let date = get(dateString: v, from: .long) { return date }
            if let date = get(dateString: v, from: .short) { return date }
            if let date = get(dateString: v, from: .medium) { return date }
            return get(dateString: v, from: .none)
        }
        return self.value as? Date
    }
    
    /// Returns the first valid date in dateTypes list, nil otherwise
    private func attemptDateTypes(onValue value: String) -> Date? {
        for format in dateFormats {
            if let date = get(dateString: value, fromCustom: format) {
                return date
            }
        }
        return nil
    }
    
    private func get(dateString: String, from style: DateFormatter.Style) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.date(from: dateString)
    }
    
    private func get(dateString: String, fromCustom format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
    
    /// Attempts to coerce an optional bool value
    public var bool: Bool? {
        guard let v = self.value else { return nil }
        
        if let s = v as? String, s.lowercased() == "true"
            || s.lowercased() == "t" { return true }
        if let s = v as? String, s.lowercased() == "false"
            || s.lowercased() == "f" { return false }
        
        if let s = v as? String, (Int(s) ?? 0) > 0 { return true }
        if let s = v as? String, Int(s) == 0 { return false }
        
        return self.value as? Bool
    }
    
    /// Attempts to coerce an optional dictionary value
    public var dictionary: [NSObject: AnyObject]? {
        return self.value as? [NSObject: AnyObject]
    }
    
    /// Attempts to coerce an optional custom typed value
    public func type<T>() -> T? {
        if let v = self.value as? T { return v }
        return self.value as? T
    }
    
    // MARK: - Throwable Typed Values
    
    /// Attempts to coerce a non-optional string value, otherwise throw
    public func mapString() throws -> String {
        if let v = self.string { return v }
        throw MapperError.StringCoerceError("Failed to convert 'value' to type String")
    }
    
    /// Attempts to coerce a non-optional double value, otherwise throw
    public func mapDouble() throws -> Double {
        if let v = self.double { return v }
        throw MapperError.DoubleCoerceError("Failed to convert 'value' to type Double")
    }
    
    /// Attempts to coerce a non-optional int value, otherwise throw
    public func mapInt() throws -> Int {
        if let v = self.int { return v }
        throw MapperError.IntCoerceError("Failed to convert 'value' to type Int")
    }
    
    /// Attempts to coerce a non-optional float value, otherwise throw
    public func mapFloat() throws -> Float {
        if let v = self.float { return v }
        throw MapperError.FloatCoerceError("Failed to convert 'value' to type Float")
    }
    
    /// Attempts to coerce a non-optional date value, otherwise throw
    public func mapDate() throws -> Date {
        if let v = self.date { return v }
        throw MapperError.DateCoerceError("Failed to convert 'value' to type Date")
    }
    
    /// Attempts to coerce a non-optional bool value, otherwise throw
    public func mapBool() throws -> Bool {
        if let v = self.bool { return v }
        throw MapperError.BoolCoerceError("Failed to convert 'value' to type Bool")
    }
    
    /// Attempts to coerce a non-optional dictionary value, otherwise throw
    public func mapDictionary() throws -> [NSObject: AnyObject] {
        if let v = self.dictionary { return v }
        throw MapperError.BoolCoerceError("Failed to convert 'value' to type Dictionary<NSObject, AnyObject>")
    }
    
    /// Attempts to coerce a non-optional custom typed value, otherwise throw
    public func mapType<T>() throws -> T {
        if let v: T = self.type() { return v }
        throw MapperError.CustomTypeCoerceError("Failed to convert 'value' to type \(T.self)")
    }
    
    // MARK: - Mapping
    
    /// Attempts to instantiate a 'Mappable' object
    public static func map<T: Mappable>(withValue value: AnyObject) -> T? {
        return T(mapper: Mapper(value: value))
    }
    
    /// Attempts to instantiate a 'Mappable' object from the current Mapper object
    public func mapped<T: Mappable>() -> T? {
        return T(mapper: self)
    }
}
