//
// Reflect.swift
// ReflectFramework
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
//

/// Reflect Object 

open class Reflect: NSObject, ReflectProtocol ,FieldsProtocol {
    /// Idetifier of register to persistence
    public var objectId: NSNumber?
    /// Date to created register
    public var createdAt: Date?
    /// Date to changed register
    public var updatedAt: Date?
    /**
     Entity Name
     
     - returns: return name to entity
     */
    public class func entityName() -> String {
        return String(describing: self)
    }
    /**
     Ignore properties
     
     - returns: return list of properties
     */
    public class func ignoredProperties() -> Set<String> {
        return []
    }
    /**
     Initialiaze Class
     */
    override required public init(){
        super.init()
    }
}
// MARK: - Extension Reflect Configuration Data Base
public extension Reflect {
    /**
     Default Configuration for Data Base Reflect
     */
    public static var settings:Configuration!
    /**
     Configure App Group and name of Data base
     
     - parameter appGroup:  App Group information
     - parameter baseNamed: Name to Data Base
     */
    public class func configuration(_ appGroup:String, baseNamed:String) {
        settings = Configuration(defaultName: baseNamed, appGroup: appGroup)
    }
    /**
      Configure App Group and name of Data base
     
     - parameter location:  Local for save data base
     - parameter readonly:  mode read
     */
    public class func configuration(_ location: Connection.Location, readonly: Bool = false) {
        settings = Configuration(location: location, readonly: readonly)
    }
    /**
     Este metodo auxilia para o tratamentos de erros relacionsado ao Data Base
     
     - parameter block: block para executar
     
     - returns: return success is true if successfully and data object generic
     */
    @discardableResult
    public class func execute<T>(_ block: @escaping () throws -> T) -> (success:Bool, data:T?) {
        var data: T?
        var success: Bool?
        var failure: Error?
        
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
// MARK: - Extension Reflect Helper
extension Reflect {
    /**
     Este metodo auxilia para executar instruções no Data Base
     
     - parameter sql: Instrution Sql text
     
     - returns: return Array of Dictionary
     */
    public class func query(_ sql:String) -> [[String: Value?]] {
        return try! Driver<Reflect>().find(sql)
    }
    
    public class func removeDefaultSettings() {
        let fm = FileManager.default
        let path = settings.getPath()
        
        if fm.fileExists(atPath: path) {
            try! fm.removeItem(atPath: path)
        }
    }
}
