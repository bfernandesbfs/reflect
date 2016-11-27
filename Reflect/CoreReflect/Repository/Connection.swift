//
// Connection.swift
// CoreReflect
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

/// A connection to SQLite.
public final class Connection {
    
    /// The location of a SQLite database.
    public enum Location {
        case inMemory
        case temporary
        case uri(String)
    }
    
    fileprivate typealias Trace = @convention(block) (UnsafePointer<Int8>) -> Void
    fileprivate static let queueKey = DispatchSpecificKey<Int>()
    fileprivate var _handle: OpaquePointer? = nil
    fileprivate var queue = DispatchQueue(label: "com.CoreReflect", attributes: [])
    fileprivate lazy var queueContext: Int = unsafeBitCast(self, to: Int.self)
    fileprivate var trace: Trace?
    
    internal var handle: OpaquePointer { return _handle! }
    
    // MARK: - Var
    
    /// Whether or not the database was opened in a read-only state.
    public var readonly: Bool {
        return sqlite3_db_readonly(handle, nil) == 1
    }
    
    /// The last rowid inserted into the database via this connection.
    public var lastInsertRowid: Int64? {
        let rowid = sqlite3_last_insert_rowid(handle)
        return rowid > 0 ? rowid : nil
    }
    
    /// The last number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var changes: Int {
        return Int(sqlite3_changes(handle))
    }
    
    /// The total number of changes (inserts, updates, or deletes) made to the
    /// database via this connection.
    public var totalChanges: Int {
        return Int(sqlite3_total_changes(handle))
    }

    // MARK: - Initializes
    
    /// Initializes a new SQLite connection.
    ///
    /// - Parameters:
    ///
    ///   - location: The location of the database. Creates a new database if it
    ///     doesn’t already exist (unless in read-only mode).
    ///
    ///     Default: `.InMemory`.
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Returns: A new database connection.
    public init(_ location: Location = .inMemory, readonly: Bool = false) throws {
        
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        try check(sqlite3_open_v2(location.description, &_handle, flags | SQLITE_OPEN_FULLMUTEX, nil))
        queue.setSpecific(key: Connection.queueKey, value: queueContext)
    }
    
    /// Initializes a new connection to a database.
    ///
    /// - Parameters:
    ///
    ///   - filename: The location of the database. Creates a new database if
    ///     it doesn’t already exist (unless in read-only mode).
    ///
    ///   - readonly: Whether or not to open the database in a read-only state.
    ///
    ///     Default: `false`.
    ///
    /// - Throws: `Result.Error` if a connection cannot be established.
    ///
    /// - Returns: A new database connection.
    public convenience init(_ filename: String, readonly: Bool = false) throws {
        try self.init(.uri(filename), readonly: readonly)
    }
    
    deinit {
        sqlite3_close(handle)
    }
    
    // MARK: - Private Methods
    
    fileprivate func prepare(_ statement: String, _ bindings: Value?...) throws -> Statement {
        if !bindings.isEmpty {
            return try prepare(statement, bindings)
        }
        return Statement(self, statement)
    }
    
    fileprivate func run(_ statement: String, _ bindings: [Value?]) throws -> Statement {
        return try prepare(statement).run(bindings)
    }
    
    @discardableResult
    fileprivate func run(_ statement: String, _ bindings: Value?...) throws -> Statement {
        return try run(statement, bindings)
    }
    
    fileprivate func transaction(_ begin: String, _ block: @escaping () throws -> Void, _ commit: String, or rollback: String) throws {
        return try sync {
            _ = try self.run(begin)
            do {
                try block()
            } catch {
                try self.run(rollback)
                throw error
            }
            try self.run(commit)
        }
    }
    
    fileprivate func querySequence(_ statement:Statement) -> AnySequence<Row>? {
        let columnNames: [String: Int] = {
            var (columnNames, _) = ([String: Int](), 0)
            for i in 0..<statement.columnNames.count {
                columnNames[statement.columnNames[i]] = i
            }
            return columnNames
        }()
        return AnySequence { AnyIterator { statement.next().map { Row(columnNames, $0) } } }
    }
    
    
    // MARK: - Public Methods
    
    /// Executes a batch of SQL statements.
    ///
    /// - Parameter SQL: A batch of zero or more semicolon-separated SQL
    ///   statements.
    ///
    /// - Throws: `Result.Error` if query execution fails.
    public func execute(_ SQL: String) throws {
        try sync { try self.check(sqlite3_exec(self.handle, SQL, nil, nil, nil)) }
    }
    
    @discardableResult
    public func run<T: ReflectProtocol>(_ schema: Schema<T>) throws -> Statement {
        let stm = schema.statement
        return try prepare(stm.sql).run(stm.args)
    }
    
    public func runRowId<T: ReflectProtocol>(_ schema: Schema<T>) throws -> Int64 {
        return try sync {
            try self.run(schema)
            return self.lastInsertRowid!
        }
    }
    
    @discardableResult
    public func runChange<T: ReflectProtocol>(_ schema: Schema<T>) throws -> Int {
        return try sync {
            try self.run(schema)
            return self.changes
        }
    }
    
    public func prepare(_ statement: String, _ bindings: [Value?]) throws -> Statement {
        return try prepare(statement).bind(bindings)
    }

    public func prepareQuery(_ query: String) throws -> AnySequence<Row>? {
        let statement = try prepare(query)
        return querySequence(statement)
    }
    
    public func prepareQuery<T: ReflectProtocol>(_ query: Query<T>) throws -> AnySequence<Row>? {
        let stm = query.statement
        let statement = try prepare(stm.sql, stm.args)
        return querySequence(statement)
    }
    
    public func prepareFetch<T: ReflectProtocol>(_ query: Query<T>) throws -> Row? {
        return try prepareQuery(query)!.makeIterator().next()
    }

    
    /// Runs a single SQL statement (with optional parameter bindings),
    /// returning the first value of the first row.
    ///
    /// - Parameters:
    ///
    ///   - statement: A single SQL statement.
    ///
    ///   - bindings: A list of parameters to bind to the statement.
    ///
    /// - Returns: The first value of the first row returned.
    public func scalar<T: ReflectProtocol>(_ query: Query<T>) throws -> Value? {
        let stm = query.statement
        return try prepare(stm.sql).scalar(stm.args)
    }

    
    // TODO: Consider not requiring a throw to roll back?
    /// Runs a transaction with the given mode.
    ///
    /// - Note: Transactions cannot be nested. To nest transactions, see
    ///   `savepoint()`, instead.
    ///
    /// - Parameters:
    ///
    ///   - mode: The mode in which a transaction acquires a lock.
    ///
    ///     Default: `.Deferred`
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The transaction will be committed when the block returns. The block
    ///     must throw to roll the transaction back.
    ///
    /// - Throws: `Result.Error`, and rethrows.
    public func transaction(_ mode: TransactionMode = .Deferred, block: @escaping () throws -> Void) throws {
        try transaction("BEGIN \(mode.rawValue) TRANSACTION", block, "COMMIT TRANSACTION", or: "ROLLBACK TRANSACTION")
    }
    
    // TODO: Consider not requiring a throw to roll back?
    // TODO: Consider removing ability to set a name?
    /// Runs a transaction with the given savepoint name (if omitted, it will
    /// generate a UUID).
    ///
    /// - SeeAlso: `transaction()`.
    ///
    /// - Parameters:
    ///
    ///   - savepointName: A unique identifier for the savepoint (optional).
    ///
    ///   - block: A closure to run SQL statements within the transaction.
    ///     The savepoint will be released (committed) when the block returns.
    ///     The block must throw to roll the savepoint back.
    ///
    /// - Throws: `SQLite.Result.Error`, and rethrows.
    public func savepoint(_ name: String = UUID().uuidString, block: @escaping () throws -> Void) throws {
        let name = name.quote(mark: "'")
        let savepoint = "SAVEPOINT \(name)"
        
        try transaction(savepoint, block, "RELEASE \(savepoint)", or: "ROLLBACK TO \(savepoint)")
    }
    
    /// Interrupts any long-running queries.
    public func interrupt() {
        sqlite3_interrupt(handle)
    }
    
    /// Sets a handler to call when a statement is executed with the compiled
    /// SQL.
    ///
    /// - Parameter callback: This block is invoked when a statement is executed
    ///   with the compiled SQL as its argument.
    ///
    ///       db.trace { SQL in print(SQL) }
    public func trace(_ callback: ((String) -> Void)?) {
        guard let callback = callback else {
            sqlite3_trace(handle, nil, nil)
            trace = nil
            return
        }
        
        let box: Trace = { callback(String(cString: $0)) }
        sqlite3_trace(handle, { callback, SQL in
            unsafeBitCast(callback, to: Trace.self)(SQL!)
            }, unsafeBitCast(box, to: UnsafeMutableRawPointer.self))
        trace = box
    }
    
    // MARK: - Error Handling
    
    @discardableResult
    public func sync<T>(_ block: @escaping () throws -> T) rethrows -> T {
        var success: T?
        var failure: Error?
        
        let box: () -> Void = {
            do {
                success = try block()
            } catch {
                failure = error
            }
        }
        
        if DispatchQueue.getSpecific(key: Connection.queueKey) == queueContext {
            box()
        } else {
            queue.sync(execute: box)
        }
        
        if let failure = failure {
            try { () -> Void in throw failure }()
        }
        
        return success!
    }
    
    @discardableResult
    public func check(_ resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        guard let error = Result(errorCode: resultCode, connection: self, statement: statement) else {
            return resultCode
        }
        throw error
    }
}

extension Connection : CustomStringConvertible {
    
    /// The mode in which a transaction acquires a lock.
    public enum TransactionMode : String {
        /// Defers locking the database till the first read/write executes.
        case Deferred = "DEFERRED"
        /// Immediately acquires a reserved lock on the database.
        case Immediate = "IMMEDIATE"
        /// Immediately acquires an exclusive lock on all databases.
        case Exclusive = "EXCLUSIVE"
    }
    
    public var description: String {
        return String(cString: sqlite3_db_filename(handle, nil))
    }
}

extension Connection.Location : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .inMemory:
            return ":memory:"
        case .temporary:
            return ""
        case .uri(let URI):
            return URI
        }
    }
}

public enum Result : Error {
    
    fileprivate static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]
    
    case error(message: String, code: Int32, statement: Statement?)
    
    init?(errorCode: Int32, connection: Connection, statement: Statement? = nil) {
        guard !Result.successCodes.contains(errorCode) else { return nil }
        
        let message = String(cString: sqlite3_errmsg(connection.handle))
        self = .error(message: message, code: errorCode, statement: statement)
    }
}

extension Result : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .error(message, _, statement):
            guard let statement = statement else { return message }
            return "\(message) (\(statement))"
        }
    }
    
    public var errorCode: Int {
        switch self {
        case let .error(_, code, statement):
            guard let _ = statement else { return Int(code) }
            return Int(code)
        }
    }
}
