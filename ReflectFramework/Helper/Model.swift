//
//  Model.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

struct MirrorModel {
    var key:String
    var value:AnyObject!
    var type:String
    
    static func getValues(properties:[MirrorModel]) -> [AnyObject?] {
        var list:[AnyObject?] = [AnyObject]()
        for property in properties {
            if let obj = property.value {
                list.append(obj)
            }
            else{
                list.append(nil)
            }
        }
        return list
    }
}