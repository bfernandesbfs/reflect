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
    public var createdAt: NSDate?
    /// Date to changed register
    public var updatedAt: NSDate?
    /**
     Entity Name
     
     - returns: return name to entity
     */
    public class func entityName() -> String {
        return String(self)
    }
    /**
     Primary keys
     
     - returns: return list to the primary keys
     */
    public class func primaryKeys() -> Set<String> {
        return []
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
    public static var settings:Configuration = Configuration.defaultSettings()
    /**
     Configure App Group and name of Data base
     
     - parameter appGroup:  App Group information
     - parameter baseNamed: Name to Data Base
     */
    class func configuration(appGroup:String, baseNamed:String){
        settings = Configuration(defaultName: baseNamed, appGroup: appGroup)
    }
    /**
      Configure App Group and name of Data base
     
     - parameter appGroup:  App Group information
     - parameter baseNamed: Name to Data Base
     - parameter location:  Local for save data base
     - parameter readonly:  mode read
     */
    class func configuration(appGroup:String, baseNamed:String, location: Connection.Location, readonly: Bool = false){
        settings = Configuration(defaultName: baseNamed, appGroup: appGroup, location: location, readonly: readonly)
    }
    /**
     Este metodo auxilia para o tratamentos de erros relacionsado ao Data Base
     
     - parameter block: block para executar
     
     - returns: return success is true if successfully and data object generic
     */
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
// MARK: - Extension Reflect Helper
extension Reflect {
    /**
     Este metodo auxilia para executar instruções no Data Base
     
     - parameter sql: Instrution Sql text
     
     - returns: return Array of Dictionary
     */
    public class func query(sql:String) -> [[String: Value?]] {
        return try! Driver<Reflect>().find(sql)
    }
    
}