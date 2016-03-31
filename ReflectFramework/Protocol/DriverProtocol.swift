//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public protocol DriverProtocol {
    associatedtype T: ReflectProtocol
    func create(obj: T.Type) throws
    func drop(obj: T.Type) throws
    func removeAll(obj: T.Type) throws
    func save(obj: T) throws
    func change(obj: T) throws -> Int
    func delete(obj: T) throws -> Int
    func fetch(obj: T) throws
    func find(id: Int) throws -> T?
    func find(query:Query<T>) throws -> [T]
    func find(query: String) throws -> [[String: Value?]]
    func find(query: Query<T>, column:String) throws -> Value?
}
