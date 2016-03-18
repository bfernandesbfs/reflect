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
        return sqlite3_column_int(handle,  Int32(idx)) != 0
    }
    
    public subscript(idx: Int) -> NSData {
        let bytes = sqlite3_column_blob(handle, Int32(idx))
        let length = Int(sqlite3_column_bytes(handle, Int32(idx)))
        return NSData(bytes: bytes, length: length)
    }
    
}

extension Cursor : SequenceType {
    
    public subscript(idx: Int) -> Value? {
        
        let columnType = sqlite3_column_type(handle, Int32(idx))
        
        switch columnType {
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
        var idx = 0
        return anyGenerator {
            idx >= self.columnCount ? Optional<Value?>.None : self[idx++]
        }
    }
    
}


public struct Row {
    
    private let columnNames: [String: Int]
    
    private let values: [Value?]
    
    public init(_ columnNames: [String: Int], _ values: [Value?]) {
        self.columnNames = columnNames
        self.values = values
    }
    
    public func get<V: Binding>(column: String) -> V {
        return get(column)!
    }
    
    private func get<V: Binding>(column: String) -> V? {
        
        func valueAtIndex(idx: Int) -> V? {
            guard let value = values[idx] as? V.Datatype else {
                return nil
            }
            
            return (V.fromDatatypeValue(value) as? V)!
        }
        
        guard let idx = columnNames[column] else {
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
    
    
    public subscript(column: String , type:Int.Type) -> Int {
        return get(column)
    }
    
    public subscript(column: String , type:String.Type) -> String {
        return get(column)
    }
    
    public subscript(column: String , type:String.Type) -> String? {
        return get(column)
    }
    
    public subscript(column: String , type:Float.Type) -> Float {
        return get(column)
    }
    
    public subscript(column: String , type:Double.Type) -> Double {
        return get(column)
    }
    
    public subscript(column: String , type:Double.Type) -> Double? {
        return get(column)
    }
    
    public subscript(column: String , type:Bool.Type) -> Bool {
        return get(column)
    }
    
    public subscript(column: String , type:Bool.Type) -> Bool? {
        return get(column)
    }
    
    public subscript(column: String , type:NSNumber.Type) -> NSNumber {
        return get(column)
    }
    
    public subscript(column: String , type:NSNumber.Type) -> NSNumber? {
        return get(column)
    }
    
    public subscript(column: String , type:NSDate.Type) -> NSDate {
        return get(column)
    }
    
    public subscript(column: String , type:NSDate.Type) -> NSDate? {
        return get(column)
    }
    
    public subscript(column: String , type:NSData.Type) -> NSData {
        return get(column)
    }
    
    public subscript(column: String , type:NSData.Type) -> NSData? {
        return get(column)
    }
    
    public subscript(index: Int) -> String {
        return Array(columnNames.keys)[index]
    }
    
    
}


