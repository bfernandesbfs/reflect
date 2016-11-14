//
// Bind.swift
// ReflectFramework
//
// Created by Bruno Fernandes on 18/03/16.
// Copyright © 2016 BFS. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

public protocol Value {}

public protocol Binding {
    associatedtype ValueType = Self
    associatedtype Datatype : Value
    static var declaredDatatype: String { get }
    static func fromDatatypeValue(_ datatypeValue: Datatype) -> ValueType
}

extension String: Value, Binding {
    public static let declaredDatatype = "TEXT"
    public static func fromDatatypeValue(_ datatypeValue: String) -> String {
        return datatypeValue
    }
}

extension Int: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Int {
        return Int(datatypeValue)
    }
}

extension Int8: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> Int8 {
        return Int8(datatypeValue)
    }
}

extension Int16: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> Int16 {
        return Int16(datatypeValue)
    }
}

extension Int32: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> Int32 {
        return Int32(datatypeValue)
    }
}

extension Int64: Value, Binding  {
    public static let declaredDatatype = "INTEGER"
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Int64 {
        return datatypeValue
    }
}

extension UInt: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> UInt {
        return UInt(datatypeValue)
    }
}

extension UInt8: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> UInt8 {
        return UInt8(datatypeValue)
    }
}

extension UInt16: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> UInt16 {
        return UInt16(datatypeValue)
    }
}

extension UInt32: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> UInt32 {
        return UInt32(datatypeValue)
    }
}

extension UInt64: Value, Binding {
    public static var declaredDatatype = Int64.declaredDatatype
    public static func fromDatatypeValue(_ datatypeValue: Int) -> UInt64 {
        return UInt64(datatypeValue)
    }
}

extension Double: Value, Binding  {
    public static let declaredDatatype = "DOUBLE"
    public static func fromDatatypeValue(_ datatypeValue: Double) -> Double {
        return  datatypeValue
    }
}

extension Float: Value, Binding {
    public static let declaredDatatype = "FLOAT"
    public static func fromDatatypeValue(_ datatypeValue: Double) -> Float {
        return Float(datatypeValue)
    }
}

extension Bool: Value, Binding  {
    public static var declaredDatatype = "BOOLEAN"
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Bool {
        return datatypeValue != 0
    }
    
    public var datatypeValue: Int {
        return self ? 1 : 0
    }
}

extension Date: Value, Binding {
    public static var declaredDatatype:String {
        return "DATE"
    }
    public static func fromDatatypeValue(_ datatypeValue: String) -> Date {
        return dateFormatter.date(from: datatypeValue)!
    }
    
    public var datatypeValue: String {
        return dateFormatter.string(from: self)
    }
}

extension Data: Value, Binding {
    public static var declaredDatatype:String {
        return "BLOB"
    }
    public static func fromDatatypeValue(_ datatypeValue: Data) -> Data {
        return datatypeValue
    }
    
    public var datatypeValue: String {
        return "x'\(toHex())'"
    }
    
    fileprivate func toHex() -> String {
        let bytes: [UInt8] = [UInt8](UnsafeBufferPointer(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count), count: count))
        return bytes.map {
            ($0 < 16 ? "0" : "") + String($0, radix: 16, uppercase: false)
            }.joined(separator: "")
    }
}

// OBJC
extension NSString: Value, Binding {
    public class var declaredDatatype:String {
        return String.declaredDatatype
    }
    public class func fromDatatypeValue(_ datatypeValue: String) -> String {
        return datatypeValue
    }
}

extension NSNumber: Value, Binding {
    public class var declaredDatatype:String {
        return "NUMERIC"
    }
    public class func fromDatatypeValue(_ datatypeValue: NSNumber) -> NSNumber {
        return datatypeValue
    }
}
