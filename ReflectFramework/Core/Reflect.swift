//
//  Reflect.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

class Reflect: Initable {
    var id:Int?
    
    private static var drive:Driver = Service<Reflect>()
    
    required init(){
        id = 0
    }
    
    class func tableName() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    class func register() {
        Reflect.drive.create(self.init())
    }
    
    class func unRegister() {
        Reflect.drive.destroy()
    }
    
    class func unPinAll() -> Bool {
        return Reflect.drive.delete(0)
    }
    
    func fetch() {
        Reflect.drive.fetchOne(id!)
    }
    
    func pin() -> Bool {
        return Reflect.drive.insert(self)
    }
    
    func unPin() -> Bool {
        return Reflect.drive.delete(id!)
    }
    
}