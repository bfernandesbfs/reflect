//
// Configuration.swift
// CoreReflect
//
// Created by Bruno Fernandes on 18/03/16.
// Copyright © 2016 BFS. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
///

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
