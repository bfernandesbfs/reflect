//
// Drive.swift
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
    func create(_ obj: T.Type) throws
    /**
     Delete a Object with name relation with object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func drop(_ obj: T.Type) throws
    /**
     Create Index to object
     
     - parameter obj:    Object Reflect
     - parameter field:  Column names that the index will be applied
     - parameter unique: True if the index should be unique, false if it should not be unique (defaults to false)
     
     - throws: `Result.Error`
     
     */
    func index(_ obj:T.Type, field: String, unique: Bool) throws
    /**
     Drop Index to object
     
     - parameter obj:   Object Reflect
     - parameter field: Column names that the index will be applied
     
     - throws: `Result.Error`
     
     */
    func dropIndex(_ obj: T.Type, field: String) throws
    /**
     Delete all Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func removeAll(_ obj: T.Type) throws
    /**
     Save or Update Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     */
    func save(_ obj: T) throws
    /**
     Change Object
     
     - parameter obj: Object Reflect
     
     - throws:  `Result.Error`
     
     - returns: total of changes
     */
    func change(_ obj: T) throws -> Int
    /**
     Delete Object
     
     - parameter obj: Object Reflect
     
     - throws: `Result.Error`
     
     - returns: total of changes
     */
    func delete(_ obj: T) throws -> Int
    /**
     Select One
     
     - parameter obj:     Object Reflect
     - parameter include: Class in conform with protocol Reflect Protocol
     
     - throws:  `Result.Error`
    
     */
    func fetch(_ obj: T, include:[Any.Type]) throws
    /**
     Select Object with objectId
     
     - parameter id:      objectId selected
     - parameter include: Class in conform with protocol Reflect Protocol
     
     - throws: `Result.Error`
     
     - returns: return a new instance to Object Reflect
     */
    func find(_ id: Int, include:[Any.Type]) throws -> T?
    /**
     Select Objects with Query Filter
     
     - parameter query: Query filter
     
     - throws: `Result.Error`
     
     - returns: return a new instances to Objects of type Reflect
     */
    func find(_ query:Query<T>) throws -> [T]
    /**
     Select Objects
     
     - parameter query: String query
     
     - throws: `Result.Error`
     
     - returns: return Array Dictionary
     */
    func find(_ query: String) throws -> [[String: Value?]]
    /**
     Select Object
     
     - parameter query:  Query object
     - parameter column: Field name
     
     - throws: `Result.Error`
     
     - returns: Return a value 
     */
    func scalar(_ query: Query<T>, column:String) throws -> Value?
    /**
     Transaction Object
     
     - parameter obj:  Object
     - parameter callBack: Call back to querys
     
     - throws: `Result.Error`

     */
    func transaction(_ obj: T.Type, callback: @escaping () throws -> Void) throws
    
    func log(_ callback: ((String) -> Void)?)
}
