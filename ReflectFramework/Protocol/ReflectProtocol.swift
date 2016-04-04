//
//  ReflectProtocol.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public protocol ReflectProtocol {
    var objectId:NSNumber? { get set }
    var createAt:NSDate? {get set}
    var updateAt:NSDate? {get set}
    init()
    static func entityName() -> String
}

public protocol FieldsProtocol {
    static func primaryKeys() -> Set<String>
    static func ignoredProperties() -> Set<String>
}

extension ReflectProtocol {
    static func query() -> Query<Self> {
        return Query()
    }
    
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
    
    static func findObject(query:Query<Self>) -> [Self] {
        return Reflect.execute {
            return try Driver().find(query)
            }.data!
    }
    
    static func findById(id: Int, include:Any.Type...) -> Self? {
        return Reflect.execute {
            return try Driver().find(id, include: include)
            }.data!
    }
    
    static func clean() -> Bool {
        return Reflect.execute {
            return try Driver().removeAll(self)
            }.success
    }
}

extension ReflectProtocol {
    
    func fetch(include include:Any.Type...) -> Bool {
        return Reflect.execute {
            try Driver().fetch(self, include: include)
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
