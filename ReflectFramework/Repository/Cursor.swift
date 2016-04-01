//
//  Cursor.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public struct Cursor {
    
    private let handle: COpaquePointer
    private let columnCount: Int
    
    public init(_ statement: Statement) {
        handle = statement.handle
        columnCount = statement.columnCount
    }
    
    public subscript(idx: Int) -> Int64 {
        return sqlite3_column_int64(handle, Int32(idx))
    }
    
    public subscript(idx: Int) -> Int {
        return Int.fromDatatypeValue(self[idx])
    }
    
    public subscript(idx: Int) -> String {
        return String.fromCString(UnsafePointer(sqlite3_column_text(handle, Int32(idx)))) ?? ""
    }
    
    public subscript(idx: Int) -> Double {
        return sqlite3_column_double(handle, Int32(idx))
    }
    
    public subscript(idx: Int) -> Bool {
        return Bool.fromDatatypeValue(self[idx])
    }
    
    public subscript(idx: Int) -> NSData {
        let bytes = sqlite3_column_blob(handle, Int32(idx))
        let length = Int(sqlite3_column_bytes(handle, Int32(idx)))
        return NSData(bytes: bytes, length: length)
    }
    
}

extension Cursor : SequenceType {
    
    public subscript(idx: Int) -> Value? {
        switch sqlite3_column_type(handle, Int32(idx)) {
        case SQLITE_INTEGER:
            return self[idx] as Int64
        case SQLITE_TEXT:
            return self[idx] as String
        case SQLITE_FLOAT:
            return self[idx] as Double
        case SQLITE_BLOB:
            return self[idx] as NSData
        case SQLITE_NULL:
            return nil
        case let type:
            fatalError("unsupported column type: \(type)")
        }
    }
    
    public func generate() -> AnyGenerator<Value?> {
        var idx = -1
        return AnyGenerator {
            idx >= self.columnCount ? Optional<Value?>.None : self[self.incrementIdx(&idx)]
        }
    }
    
    public func incrementIdx(inout idx:Int) -> Int{
        idx = idx + 1
        return idx
    }
    
}


public struct Row {
    
    private let columnNames: [String: Int]
    
    private let values: [Value?]
    
    public init(_ columnNames: [String: Int], _ values: [Value?]) {
        self.columnNames = columnNames
        self.values = values
    }
    
    public func get(column: String) -> RowValue {
        
        func valueAtIndex(idx: Int) -> RowValue {
            return RowValue(obj: values[idx])
        }
        
        guard let idx = columnNames[column] else {
            print(column)
            let similar = Array(columnNames.keys).filter { $0.hasSuffix(".\(column)") }
            
            switch similar.count {
            case 0:
                fatalError("no such column '\(column)' in columns: \(columnNames.keys.sort())")
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
    
    public func asDate() -> NSDate? {
        guard let v = value as? String else {
            return nil
        }
        return NSDate.fromDatatypeValue(v)
    }
    
    public func asData() -> NSData? {
        return value as? NSData
    }
    
    public func asAnyObject() -> AnyObject? {
        return value as? AnyObject
    }
    
    public func asValue() -> Value? {
        return value
    }
    
    // MARK: - Private Methods
    private func checkNumber() -> NSNumber? {
        if value != nil {
            let mirror = Mirror(reflecting: value)
            switch unwrapType(mirror.children.first!.value) {
            case is Int.Type, is Int64.Type:
                return asInt() as NSNumber?
            case is Float.Type:
                return asFloat() as NSNumber?
            case is Double.Type:
                return asDouble() as NSNumber?
            case is String.Type:
                if let stringValue = asString() {
                    return Int(stringValue)
                }
                return nil
            default:
                return nil
            }
        }
        
        return nil
    }

    private func unwrapType(value: Any) -> Any.Type {
        let mirror = Mirror(reflecting: value)
        return mirror.subjectType
    }
    
}