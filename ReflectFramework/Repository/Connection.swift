//
//  Connection.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

/// A connection to SQLite.
public final class Connection {
    
    /// The location of a SQLite database.
    public enum Location {
        case InMemory
        case Temporary
        case URI(String)
    }
    
    public var handle: COpaquePointer { return _handle }
    
    private var _handle: COpaquePointer = nil
    
    private var queue = dispatch_queue_create("br.com.bfs.BaseFramework", DISPATCH_QUEUE_SERIAL)
    
    private static let queueKey = unsafeBitCast(Connection.self, UnsafePointer<Void>.self)
    
    private lazy var queueContext: UnsafeMutablePointer<Void> = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
    
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
    public init(_ location: Location = .InMemory, readonly: Bool = false) throws {
        let flags = readonly ? SQLITE_OPEN_READONLY : SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
        try check(sqlite3_open_v2(location.description, &_handle, flags | SQLITE_OPEN_FULLMUTEX, nil))
        dispatch_queue_set_specific(queue, Connection.queueKey, queueContext, nil)
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
        try self.init(.URI(filename), readonly: readonly)
    }
    
    deinit {
        sqlite3_close(handle)
    }
    
    // MARK: -
    
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
    
    // MARK: - Execute
    
    /// Executes a batch of SQL statements.
    ///
    /// - Parameter SQL: A batch of zero or more semicolon-separated SQL
    ///   statements.
    ///
    /// - Throws: `Result.Error` if query execution fails.
    public func execute(SQL: String) throws {
        try sync { try self.check(sqlite3_exec(self.handle, SQL, nil, nil, nil)) }
    }
    
    func prepare(statement: String, _ bindings: AnyObject?...) -> Statement {
        if !bindings.isEmpty {
            return prepare(statement, bindings)
        }
        return Statement(self, statement)
    }
    
    public func prepare(statement: String, _ bindings: [AnyObject?]) -> Statement {
        return prepare(statement).bind(bindings)
    }
    
    public func run(statement: String, _ bindings: AnyObject?...) throws -> Statement {
        return try run(statement, bindings)
    }
    
    public func run(statement: String, _ bindings: [AnyObject?]) throws -> Statement {
        return try prepare(statement).run(bindings)
    }
    
    public func runRowId(statement: String, _ bindings: [AnyObject?]) throws -> Int64 {
        return try sync {
            try self.run(statement ,bindings)
            return self.lastInsertRowid!
        }
    }
    
    public func runChange(statement: String, _ bindings: AnyObject?...) throws -> Int {
        return try sync {
            try self.run(statement ,bindings)
            return self.changes
        }
    }
    
    public func runChange(statement: String, _ bindings: [AnyObject?]) throws -> Int {
        return try sync {
            try self.run(statement ,bindings)
            return self.changes
        }
    }
    
    
    
    // MARK: - Transactions
    
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
    public func transaction(mode: TransactionMode = .Deferred, block: () throws -> Void) throws {
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
    public func savepoint(name: String = NSUUID().UUIDString, block: () throws -> Void) throws {
        let name = name.quote("'")
        let savepoint = "SAVEPOINT \(name)"
        
        try transaction(savepoint, block, "RELEASE \(savepoint)", or: "ROLLBACK TO \(savepoint)")
    }
    
    private func transaction(begin: String, _ block: () throws -> Void, _ commit: String, or rollback: String) throws {
        return try sync {
            try self.run(begin)
            do {
                try block()
            } catch {
                try self.run(rollback)
                throw error
            }
            try self.run(commit)
        }
    }
    
    /// Interrupts any long-running queries.
    public func interrupt() {
        sqlite3_interrupt(handle)
    }
    
    // MARK: - Error Handling
    
    func sync<T>(block: () throws -> T) rethrows -> T {
        var success: T?
        var failure: ErrorType?
        
        let box: () -> Void = {
            do {
                success = try block()
            } catch {
                failure = error
            }
        }
        
        if dispatch_get_specific(Connection.queueKey) == queueContext {
            box()
        } else {
            dispatch_sync(queue, box)
        }
        
        if let failure = failure {
            try { () -> Void in throw failure }()
        }
        
        return success!
    }
    
    func check(resultCode: Int32, statement: Statement? = nil) throws -> Int32 {
        guard let error = Result(errorCode: resultCode, connection: self, statement: statement) else {
            return resultCode
        }
        
        throw error
    }
    
}

extension Connection {
    
    public func prepareQuery(statement: String, _ bindings: [AnyObject?]) throws -> AnySequence<Row>? {
        let statement = prepare(statement, bindings)
        
        let columnNames: [String: Int] = {
            var (columnNames, _) = ([String: Int](), 0)
            for i in 0..<statement.columnNames.count {
                columnNames[statement.columnNames[i]] = i
            }
            return columnNames
        }()
        
        return AnySequence { anyGenerator { statement.next().map { Row(columnNames, $0) } } }
    }
    
    public func prepareFetch(statement: String, _ bindings: AnyObject?...) throws -> Row? {
        return try prepareQuery(statement, bindings)!.generate().next()
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
        return String.fromCString(sqlite3_db_filename(handle, nil))!
    }
    
}

extension Connection.Location : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .InMemory:
            return ":memory:"
        case .Temporary:
            return ""
        case .URI(let URI):
            return URI
        }
    }
    
}

public enum Result : ErrorType {
    
    private static let successCodes: Set = [SQLITE_OK, SQLITE_ROW, SQLITE_DONE]
    
    case Error(message: String, code: Int32, statement: Statement?)
    
    init?(errorCode: Int32, connection: Connection, statement: Statement? = nil) {
        guard !Result.successCodes.contains(errorCode) else { return nil }
        
        let message = String.fromCString(sqlite3_errmsg(connection.handle))!
        self = Error(message: message, code: errorCode, statement: statement)
    }
    
}

extension Result : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .Error(message, _, statement):
            guard let statement = statement else { return message }
            
            return "\(message) (\(statement))"
        }
    }
    
}
