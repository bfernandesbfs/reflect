//
//  Reflect.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

class Reflect: NSObject, ReflectProtocol ,FieldsProtocol {
    var objectId:Int?
    
    class func entityName() -> String {
        return String(self)
    }
    
    class func primaryKey() -> String {
        return "objectId"
    }
    
    class func ignoredProperties() -> Set<String> {
        return []
    }
    
    override required init(){
    }
    
}

extension Reflect {
    
    static var settings:Configuration = Configuration.defaultSettings()
    
    class func configuration(appGroup:String, baseNamed:String){
        settings = Configuration(defaultName: baseNamed, appGroup: appGroup)
    }
    
    class func execute<T>(block: () throws -> T) -> (success:Bool, data:T?) {
        var data: T?
        var success: Bool?
        var failure: ErrorType?
        
        let box: () -> Void = {
            do {
                data = try block()
                success = true
            } catch {
                failure = error
            }
        }
        
        box()
        
        if let failure = failure {
            print(failure)
            data = nil
            success = false
        }
        return (success! , data)
    }
}