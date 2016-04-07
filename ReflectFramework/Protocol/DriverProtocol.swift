//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

/**
 *  Driver Protocol
 */
public protocol DriverProtocol {
    // MARK: - Type Generic in conform with protocol Reflect Protocol
    associatedtype T: ReflectProtocol
    /**
     Create a Object with the provided column names and types
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func create(obj: T.Type) throws
    /**
     Delete a Object with name relation with object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func drop(obj: T.Type) throws
    /**
     Create Index to object
     
     - parameter obj:    Object Reflect
     - parameter field:  Column names that the index will be applied
     - parameter unique: True if the index should be unique, false if it should not be unique (defaults to false)
     
     - throws: `Result.Error`
     
     */
    func index(obj:T.Type, field: String, unique: Bool) throws
    /**
     Drop Index to object
     
     - parameter obj:   Object Reflect
     - parameter field: Column names that the index will be applied
     
     - throws: `Result.Error`
     
     */
    func dropIndex(obj: T.Type, field: String) throws
    /**
     Delete all Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func removeAll(obj: T.Type) throws
    /**
     Save or Update Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func save(obj: T) throws
    /**
     Change Object
     
     - parameter obj: Object Reflect
     
     - throws:  `Result.Error`
     
     - returns: total of changes
     */
    func change(obj: T) throws -> Int
    /**
     Delete Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     - returns: total of changes
     */
    func delete(obj: T) throws -> Int
    /**
     Select One
     
     - parameter obj:     Object Reflect
     - parameter include: Class in conform with protocol Reflect Protocol
     
     - throws:  `Result.Error`
    
     */
    func fetch(obj: T, include:[Any.Type]) throws
    /**
     Select Object with objectId
     
     - parameter id:      objectId selected
     - parameter include: Class in conform with protocol Reflect Protocol
     
     - throws: `Result.Error`
     
     - returns: return a new instance to Object Reflect
     */
    func find(id: Int, include:[Any.Type]) throws -> T?
    /**
     Select Objects with Query Filter
     
     - parameter query: Query filter
     
     - throws: `Result.Error`
     
     - returns: return a new instances to Objects of type Reflect
     */
    func find(query:Query<T>) throws -> [T]
    /**
     Select Objects
     
     - parameter query: String query
     
     - throws: `Result.Error`
     
     - returns: return Array Dictionary
     */
    func find(query: String) throws -> [[String: Value?]]
    /**
     Select Object
     
     - parameter query:  Query object
     - parameter column: Field name
     
     - throws: `Result.Error`
     
     - returns: Return a value 
     */
    func scalar(query: Query<T>, column:String) throws -> Value?
    
    func transaction(obj: T.Type, callback: () throws -> Void) throws
    
    func log(callback: (String -> Void)?)
}
