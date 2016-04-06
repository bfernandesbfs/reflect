//
//  Configuration.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

/**
 *  Configuration Reflect
 */
public struct Configuration {
    /// Data base default name
    private var defaultName:String = "ReflectDB"
    /// App group
    private var appGroup:String = ""
    /**
     Initialize
     
     - parameter defaultName: Name to data base
     - parameter appGroup:    App group information
     
     */
    init(defaultName: String, appGroup: String){
        self.defaultName = defaultName + ".db"
        self.appGroup    = appGroup
    }
    /**
     Default Settings
     
     - returns: a instance to Configuration
     */
    static func defaultSettings() -> Configuration {
        return Configuration(defaultName: "ReflectDB", appGroup: "")
    }
    
    // MARK: - Public Methods
    /**
     Data Base name
     
     - returns: return string with name data base
     */
    public func getDBName() -> String {
        return defaultName
    }
    /**
     App Group information
     
     - returns: return strinf information
     */
    public func getAppGroup() -> String {
        return appGroup
    }
    /**
     Path data base
     
     - returns: return the path for data base
     */
    public func createPath() -> String {
        
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
        print(path)
        return path
    }
}