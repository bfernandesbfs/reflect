//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

protocol Driver {
    func create(obj:Reflect) throws
    func destroy() throws
    func find<T>(obj:Reflect, id:Int) throws -> T?
    func fetch(obj:Reflect) throws
    func insert(obj:Reflect) throws -> Int 
    func delete() throws -> Int
    func delete(id: Int) throws -> Int
}