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
    
    class func register() -> Bool {
        return execute {
            try Reflect.drive.create(self.init())
        }
    }
    
    class func unRegister() -> Bool {
        return execute {
            try Reflect.drive.destroy()
        }
    }
    
    class func unPinAll() -> Bool {
        return Reflect.execute {
            try Reflect.drive.delete()
        }
    }
    
    func fetch() {
        Reflect.drive.fetchOne(id!)
    }
    
    func pin() -> Bool {
        return Reflect.execute {
            let rowid = try Reflect.drive.insert(self)
            if rowid > 0 {
                self.id = rowid
            }
        }
    }
    
    func unPin() -> Bool {
        return Reflect.execute {
            try Reflect.drive.delete(self.id!)
        }
    }
    
}

extension Reflect {
    
    static var settings:ReflectSettings = ReflectSettings.defaultSettings()
    
    class func configuration(appGroup:String, baseNamed:String){
        settings = ReflectSettings(defaultName: baseNamed, appGroup: appGroup)
    }

    class func execute<T>(block: () throws -> T) -> Bool {
        var success: Bool?
        var failure: ErrorType?
        
        let box: () -> Void = {
            do {
                try block()
                success = true
            } catch {
                failure = error
            }
        }
        
        box()
        
        if let failure = failure {
            print(failure)
            success = false
        }
        
        return success!
    }
}