//
//  Statement.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public final class Statement {
    
    public var handle: COpaquePointer = nil
    
    private let connection: Connection
    
    public lazy var columnCount: Int = Int(sqlite3_column_count(self.handle))
    
    public lazy var columnNames: [String] = (0..<Int32(self.columnCount)).map {
        String.fromCString(sqlite3_column_name(self.handle, $0))!
    }
    
    /// A cursor pointing to the current row.
    public lazy var row: Cursor = Cursor(self)
    
    init(_ connection: Connection, _ SQL: String) {
        self.connection = connection
        do {
            try connection.check(sqlite3_prepare_v2(connection.handle, SQL, -1, &handle, nil))
        }catch let error {
            print(error)
        }
    }
    
    deinit {
        sqlite3_finalize(handle)
    }
    
    
    public func step() throws -> Bool {
        return try connection.sync { try self.connection.check(sqlite3_step(self.handle)) == SQLITE_ROW }
    }
    
    private func reset(clearBindings shouldClear: Bool = true) {
        sqlite3_reset(handle)
        if (shouldClear) { sqlite3_clear_bindings(handle) }
    }
    
    /// - Parameter bindings: A list of parameters to bind to the statement.
    ///
    /// - Throws: `Result.Error` if query execution fails.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func run(bindings: AnyObject?...) throws -> Statement {
        guard bindings.isEmpty else {
            return try run(bindings)
        }
        
        reset(clearBindings: false)
        repeat {} while try step()
        return self
    }
    
    /// - Parameter bindings: A list of parameters to bind to the statement.
    ///
    /// - Throws: `Result.Error` if query execution fails.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func run(bindings: [AnyObject?]) throws -> Statement {
        return try bind(bindings).run()
    }
    
    /// Binds a list of parameters to a statement.
    ///
    /// - Parameter values: A list of parameters to bind to the statement.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func bind(values: AnyObject?...) -> Statement {
        return bind(values)
    }
    
    /// Binds a list of parameters to a statement.
    ///
    /// - Parameter values: A list of parameters to bind to the statement.
    ///
    /// - Returns: The statement object (useful for chaining).
    public func bind(values: [AnyObject?]) -> Statement {
        if values.isEmpty { return self }
        reset()
        guard values.count == Int(sqlite3_bind_parameter_count(handle)) else {
            fatalError("\(sqlite3_bind_parameter_count(handle)) values expected, \(values.count) passed")
        }
        for idx in 1...values.count {
            bind(values[idx - 1], atIndex: idx)
        }
        return self
    }
    
    private func bind(value: AnyObject?, atIndex idx: Int) {
        
        if value == nil {
            sqlite3_bind_null(handle, Int32(idx))
        } else if let value = value as? NSData {
            sqlite3_bind_blob(handle, Int32(idx), value.bytes, Int32(value.length), SQLITE_TRANSIENT)
        } else if let value = value as? Double {
            sqlite3_bind_double(handle, Int32(idx), value)
        } else if let value = value as? Int64 {
            sqlite3_bind_int64(handle, Int32(idx), value)
        } else if let value = value as? String {
            sqlite3_bind_text(handle, Int32(idx), value, -1, SQLITE_TRANSIENT)
        } else if let value = value as? Int {
            sqlite3_bind_int64(handle, Int32(idx), value.toInt64())
        } else if let value = value as? Bool {
            sqlite3_bind_int(handle, Int32(idx), Int32(value.toInt()))
        } else if let value = value as? NSDate {
            sqlite3_bind_text(handle, Int32(idx), value.toString(), -1, SQLITE_TRANSIENT)
        } else if let value = value {
            fatalError("tried to bind unexpected value \(value)")
        }
    }
    
}

extension Statement : SequenceType {
    
    public func generate() -> Statement {
        reset(clearBindings: false)
        return self
    }
    
}

extension Statement : GeneratorType {
    
    public func next() -> [Value?]? {
        return try! step() ? Array(row) : nil
    }
}

extension Statement : CustomStringConvertible {
    
    public var description: String {
        return String.fromCString(sqlite3_sql(handle))!
    }
    
}


