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
    fileprivate var defaultName:String = "ReflectDB.db"
    /// App group
    fileprivate var appGroup:String = ""
    /// Connection Data Base
    fileprivate var connection: Connection!
    /**
     Initialize
     
     - parameter defaultName: Name to data base
     - parameter appGroup:    App group information
     
     */
    public init(defaultName: String, appGroup: String){
        self.defaultName = defaultName
        self.appGroup    = appGroup
        self.connection  = try! Connection(getPath())
    }
    /**
     Initialize
     
     - parameter defaultName: Name to data base
     - parameter appGroup:    App group information
     - parameter location:    Local data base
     - parameter readonly:    mode read

     */
    public init(location: Connection.Location, readonly: Bool = false) {
        do {
            self.connection  = try Connection(location , readonly: readonly)
        }
        catch let error {
            print(error)
        }
    }
    /**
     Default Settings
     
     - returns: a instance to Configuration
     */
    public static func defaultSettings() -> Configuration {
        return Configuration(defaultName: "ReflectDB.db", appGroup: "")
    }
    // MARK: - Public Methods
    /**
     Connection Data base
     
     - returns: return an instante to Connection
     */
    public func getConnection() -> Connection {
        return connection
    }
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
    public func getPath() -> String {
        
        let fm = FileManager.default
        var path:String = ""
        
        if appGroup.isEmpty {
            let docsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            path = docsPath.stringByAppendingPathComponent(path: defaultName)
        }
        else{
            
            // Get path to shared group folder
            if let url = fm.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
                path = url.path
            } else {
                assert(false, "Error getting container URL for group: \(appGroup)")
            }
            
            path = path.stringByAppendingPathComponent(path: defaultName)
            
        }
        
        return path
    }
    
    public mutating func log(_ callback: ((String) -> Void)?){
        getConnection().trace(callback)
        
        callback?(getPath())
    }

}
