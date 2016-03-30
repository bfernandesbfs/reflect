//
//  Bind.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public protocol Value {}

public protocol Text :Binding {}
public protocol Number :Binding {}
public protocol Decimal :Binding {}

public protocol Binding {
    associatedtype ValueType = Self
    associatedtype Datatype : Value
    static var declaredDatatype: String { get }
    static func fromDatatypeValue(datatypeValue: Datatype) -> ValueType
    var datatypeValue: Datatype { get }
}

extension String: Value, Text {
    public static let declaredDatatype = "TEXT"
    public static func fromDatatypeValue(datatypeValue: String) -> String {
        return datatypeValue
    }
    
    public var datatypeValue: String {
        return self
    }
}

extension Character: Value, Text {
    public static let declaredDatatype = String.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: String) -> String {
        return datatypeValue
    }

    public var datatypeValue: String {
        return String(self)
    }
}

extension Int: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension Int8: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension Int16: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension Int32: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension Int64: Value, Number  {
    public static let declaredDatatype = "INTEGER"
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int64 {
        return datatypeValue
    }
    public var datatypeValue: Int64 {
        return self
    }
}

extension UInt: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension UInt8: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension UInt16: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension UInt32: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension UInt64: Value , Number {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
    public var datatypeValue: Int64 {
        return Int64(self)
    }
}

extension Double: Value, Decimal  {
    public static let declaredDatatype = "DOUBLE"
    public static func fromDatatypeValue(datatypeValue: Double) -> Double {
        return  datatypeValue
    }
    public var datatypeValue: Double {
        return self
    }
}

extension Float: Value, Decimal {
    public static let declaredDatatype = "FLOAT"
    public static func fromDatatypeValue(datatypeValue: Double) -> Float {
        return Float(datatypeValue)
    }
    public var datatypeValue: Double {
        return Double(self)
    }
}

extension Bool: Value, Number  {
    public static var declaredDatatype = "BOOLEAN"
    public static func fromDatatypeValue(datatypeValue: Int64) -> Bool {
        return datatypeValue != 0
    }
    
    public var datatypeValue: Int64 {
        return self ? 1 : 0
    }
}

// OBJC

extension NSString: Value, Text {
    public class var declaredDatatype:String {
        return String.declaredDatatype
    }
    public class func fromDatatypeValue(datatypeValue: String) -> String {
        return datatypeValue
    }
    public var datatypeValue: String {
        return self as String
    }
}

extension NSNumber: Value, Number {
    public class var declaredDatatype:String {
        return "NUMERIC"
    }
    public class func fromDatatypeValue(datatypeValue: Int64) -> NSNumber {
        return NSNumber(longLong: datatypeValue)
    }
    public var datatypeValue: Int64 {
        return self.longLongValue
    }
}

extension NSDate: Value, Binding {
    public class var declaredDatatype:String {
        return "DATE"
    }
    public class func fromDatatypeValue(datatypeValue: String) -> NSDate {
        return dateFormatter.dateFromString(datatypeValue)!
    }
    
    public var datatypeValue: String {
        return dateFormatter.stringFromDate(self)
    }
}

extension NSData: Value, Binding {
    public class var declaredDatatype:String {
        return "BLOB"
    }
    public class func fromDatatypeValue(datatypeValue: NSData) -> NSData {
        return datatypeValue
    }
    public var datatypeValue: NSData {
        return self
    }
}

