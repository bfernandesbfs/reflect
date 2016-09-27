//
//  Reflect.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

/// Reflect Object 
//  Esta class controla todos a parte que transformar as class herdeira compativel 
//  com os objetos para o Data Base SQLITE
//  Atribua as class para herdar o Reflect Objec e ter suporta a toda persistencias 
//  dos dados no SQLite e support aos relacionamentos entres class

public class Reflect: NSObject, ReflectProtocol ,FieldsProtocol {
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
    public class func configuration(_ appGroup:String, baseNamed:String){
        settings = Configuration(defaultName: baseNamed, appGroup: appGroup)
    }
    /**
      Configure App Group and name of Data base
     
     - parameter location:  Local for save data base
     - parameter readonly:  mode read
     */
    public class func configuration(_ location: Connection.Location, readonly: Bool = false){
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
    
    public class func removeDefaultSettings(){
        let fm = FileManager.default
        let path = settings.getPath()
        
        if fm.fileExists(atPath: path) {
            try! fm.removeItem(atPath: path)
        }
    }
}
