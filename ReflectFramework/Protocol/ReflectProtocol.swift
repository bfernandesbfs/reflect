//
//  ReflectProtocol.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public protocol ReflectProtocol {
    var objectId:Int? { get set }
    init()
    static func entityName() -> String
}

public protocol FieldsProtocol {
    static func primaryKey() -> String
    static func ignoredProperties() -> Set<String>
}

extension ReflectProtocol {
    
    static func register() -> Bool {
        return Reflect.execute {
            return try Driver().create(self)
        }.success
    }
    
    static func unRegister() -> Bool {
        return Reflect.execute {
            return try Driver().drop(self)
        }.success
    }
    
    static func findById(id: Int) -> Self? {
        return Reflect.execute {
            return try Driver().find(id)
        }.data!
    }
    
    static func clean() -> Bool {
        return Reflect.execute {
            return try Driver().removeAll(self)
        }.success
    }
    
    func fetch() -> Bool {
        return Reflect.execute {
            try Driver().fetch(self)
        }.success
    }
    
    mutating func pin() -> Bool {
        return Reflect.execute {
            try Driver().save(self)
        }.success
    }
    
    func unPin() -> Bool {
        return Reflect.execute {
            try Driver().delete(self)
        }.success
    }
    
}
