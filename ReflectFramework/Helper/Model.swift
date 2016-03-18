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

struct ReflectSettings {
    private var defaultName:String = "ReflectDB"
    private var appGroup:String = ""
    
    init(defaultName: String, appGroup: String){
        self.defaultName = defaultName + ".db"
        self.appGroup    = appGroup
    }
    
    static func defaultSettings() -> ReflectSettings {
        return ReflectSettings(defaultName: "ReflectDB", appGroup: "")
    }
    
    /*
    // MARK: - Public Methods
    */
    func getDBName() -> String {
        return defaultName
    }
    
    func getAppGroup() -> String {
        return appGroup
    }
    
    func createPath() -> String {
        
        let fm = NSFileManager.defaultManager()
        
        var path:String = ""
        
        if appGroup.isEmpty {
            let docsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
            path = docsPath.stringByAppendingPathComponent(defaultName)
        }
        else{
            
            // Get path to shared group folder
            if let url = fm.containerURLForSecurityApplicationGroupIdentifier(appGroup) {
                path = url.path!
            } else {
                assert(false, "Error getting container URL for group: \(appGroup)")
            }
            
            path = path.stringByAppendingPathComponent(defaultName)
            
        }
        
        return path
    }
}