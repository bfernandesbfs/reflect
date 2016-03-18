//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

protocol Driver {
    func create(obj:AnyObject)
    func destroy()
    func fetchOne(id: Int)
    func insert(obj:AnyObject) -> Bool
    func upsert() -> Bool
    func delete(id: Int) -> Bool
}