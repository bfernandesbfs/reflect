//
//  Reflect.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

class Reflect: NSObject, Initable {
    var id:Int?
    
    private static var drive:Driver = Service<Reflect>()
    
    required override init(){
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
    
    static func findById(id: Int) -> Self? {
        do {
            return try Reflect.drive.find(self.init(), id: id)
        }
        catch{
            return nil
        }
    }
    
    func fetch() -> Bool {
        return Reflect.execute {
            try Reflect.drive.fetch(self)
        }
    }
    
    func pin() -> Bool {
        return Reflect.execute {
            let rowid = try Reflect.drive.insert(self)
            if self.id == 0 && rowid > 0 {
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