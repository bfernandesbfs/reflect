//
// Cursor.swift
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

import Foundation

public struct Cursor {
    
    fileprivate let handle: OpaquePointer
    fileprivate let columnCount: Int
    
    public init(_ statement: Statement) {
        handle = statement.handle!
        columnCount = statement.columnCount
    }
    
    public subscript(idx: Int) -> Int64 {
        return sqlite3_column_int64(handle, Int32(idx))
    }
    
    public subscript(idx: Int) -> Int {
        return Int.fromDatatypeValue(self[idx])
    }
    
    public subscript(idx: Int) -> String {
        guard let s = UnsafePointer(sqlite3_column_text(handle, Int32(idx))) else {
            return ""
        }
        return String(cString: s)
    }
    
    public subscript(idx: Int) -> Double {
        return sqlite3_column_double(handle, Int32(idx))
    }
    
    public subscript(idx: Int) -> Bool {
        return Bool.fromDatatypeValue(self[idx])
    }
    
    public subscript(idx: Int) -> Data {
        guard let bytes = sqlite3_column_blob(handle, Int32(idx)) else {
            return Data()
        }
        let length = Int(sqlite3_column_bytes(handle, Int32(idx)))
        return Data(bytes: bytes, count: length)
    }
}

extension Cursor: Sequence {
    
    public subscript(idx: Int) -> Value? {
        switch sqlite3_column_type(handle, Int32(idx)) {
        case SQLITE_INTEGER:
            return self[idx] as Int64
        case SQLITE_TEXT:
            return self[idx] as String
        case SQLITE_FLOAT:
            return self[idx] as Double
        case SQLITE_BLOB:
            return self[idx] as Data
        case SQLITE_NULL:
            return nil
        case let type:
            fatalError("unsupported column type: \(type)")
        }
    }

    public func makeIterator() -> AnyIterator<Value?> {
        var idx = -1
        return AnyIterator {
            idx >= self.columnCount ? Optional<Value?>.none : self[self.incrementIdx(&idx)]
        }
    }
    
    public func incrementIdx(_ idx:inout Int) -> Int{
        idx = idx + 1
        return idx
    }
    
}

public struct Row {
    
    fileprivate let columnNames: [String: Int]
    fileprivate let values: [Value?]
    
    public init(_ columnNames: [String: Int], _ values: [Value?]) {
        self.columnNames = columnNames
        self.values = values
    }
    
    public func get(_ column: String) -> RowValue {
        
        func valueAtIndex(_ idx: Int) -> RowValue {
            return RowValue(obj: values[idx])
        }
        
        guard let idx = columnNames[column] else {
            print(column)
            let similar = Array(columnNames.keys).filter { $0.hasSuffix(".\(column)") }
            
            switch similar.count {
            case 0:
                fatalError("no such column '\(column)' in columns: \(columnNames.keys.sorted())")
            case 1:
                return valueAtIndex(columnNames[similar[0]]!)
            default:
                fatalError("ambiguous column '\(column)' (please disambiguate: \(similar))")
            }
        }
        
        return valueAtIndex(idx)
    }
    
    public subscript(column: String) -> RowValue {
        return get(column)
    }
    
    public subscript(column: String) -> Bool {
        return !(columnNames[column] == nil)
    }

    public subscript(index: Int) -> String {
        return Array(columnNames.keys)[index]
    }
    
    public subscript(index: Int) -> [String] {
        return Array(columnNames.keys)
    }
}

public struct RowValue {
    
    var value: Value?
    init(obj: Value?) {
        value = obj
    }
    
    public func asString() -> String? {
        return value as? String
    }
    
    public func asInt() -> Int? {
        guard let v = value as? Int64 else {
            return nil
        }
        return Int.fromDatatypeValue(v)
    }
    
    public func asInt64() -> Int64? {
        return value as? Int64
    }
    
    public func asUInt() -> UInt? {
        return value as? UInt
    }
    
    public func asDouble() -> Double? {
        return value as? Double
    }
    
    public func asFloat() -> Float? {
        return value as? Float
    }
    
    public func asBool() -> Bool? {
        return value as? Bool
    }
    
    public func asNumber() -> NSNumber? {
        return checkNumber()
    }
    
    public func asDate() -> Date? {
        guard let v = value as? String else {
            return nil
        }
        return Date.fromDatatypeValue(v)
    }
    
    public func asData() -> Data? {
        return value as? Data
    }
    
    public func asAnyObject() -> AnyObject? {
        return value as AnyObject?
    }
    
    public func asValue() -> Value? {
        return value
    }
    
    // MARK: - Private Methods
    fileprivate func checkNumber() -> NSNumber? {
        if let v = value {
            let mirror = Mirror(reflecting: v)
            switch mirror.subjectType {
            case is Int.Type, is Int64.Type:
                return asInt() as NSNumber?
            case is Float.Type:
                return asFloat() as NSNumber?
            case is Double.Type:
                return asDouble() as NSNumber?
            case is String.Type:
                if let stringValue = asString() {
                    return Int(stringValue) as NSNumber?
                }
                return nil
            default:
                return nil
            }
        }
        
        return nil
    }

    fileprivate func unwrapType(_ value: Any) -> Any.Type {
        let mirror = Mirror(reflecting: value)
        return mirror.subjectType
    }
}
