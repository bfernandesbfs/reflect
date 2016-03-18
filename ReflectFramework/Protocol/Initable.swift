//
//  Initable.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

protocol Initable {
    var id: Int? { get }
    
    init()
    static func tableName() -> String
    static func register()
    static func unRegister()
    static func unPinAll() -> Bool
}