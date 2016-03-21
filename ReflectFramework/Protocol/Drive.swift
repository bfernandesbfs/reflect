//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

protocol Driver {
    func create(obj:AnyObject) throws
    func destroy() throws
    func fetchOne(id: Int)
    func insert(obj:AnyObject) throws -> Int 
    func upsert() -> Bool
    func delete() throws -> Int
    func delete(id: Int) throws -> Int
}