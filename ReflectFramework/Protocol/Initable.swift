//
//  Initable.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

protocol Initable {
    var id: Int? { get }
    
    //init()
    static func tableName() -> String
    static func register() -> Bool
    static func unRegister() -> Bool
    static func unPinAll() -> Bool
    static func findById(id:Int) -> Self?
}

extension Initable {    
    static func query() -> Query<Self> {
        return Query()
    }
}