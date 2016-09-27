//
//  Schema.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public enum Schema<T: ReflectProtocol> {
    
    case create(T)
    case drop(String)
    case index(entity:String, field: String , unique: Bool)
    case dropIndex(entity:String, field: String)
    case insert(T)
    case update(T)
    case delete(T)
    
    var statement: (sql:String, args:[Value?]) {
        switch self {
        case .create(let object):
            let tableName =  T.entityName()
            var statement = "CREATE TABLE IF NOT EXISTS " + tableName + " ("
            var fields:[String] = []
            
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId"])
            
            statement += "objectId INTEGER PRIMARY KEY AUTOINCREMENT, "
            let _ = propertyData.forEach { value in
                var data:String = ""
                if value.isClass {
                    if let sub = value.type as? Reflect.Type {
                        data = "\(sub.entityName())_objectId INTEGER"
                    }
                }
                else {
                    data = "\(value.name!) \(ReflectData.validPropertyTypeForSchema(value.type!))"
                }
                
                data += value.isOptional ? "" : " NOT NULL"
                fields.append(data)
            }

            statement += "\(fields.joined(separator: ", ")))"
        
            return (statement, [])
        
        case .drop(let tableName):
            return ("DROP TABLE \(tableName)" , [])
            
        case .index(let entityName, let field , let unique):
            var statement = unique ? "CREATE UNIQUE INDEX" : "CREATE INDEX"
            statement += " IF NOT EXISTS index_\(entityName)_on_\(field) ON \(entityName) (\(field))"
            
            return (statement , [])
        
        case .dropIndex(let entityName, let field):
            var statement = "DROP INDEX"
            statement += " IF EXISTS index_\(entityName)_on_\(field)"

            return (statement , [])
            
        case .insert(var object):
            var statement = "INSERT INTO " + T.entityName()
            object.createdAt = Date()
            object.updatedAt = object.createdAt
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId"])
            
            var dataArgs:[Value?] = []
            var placeholder:[String] = []
            let columns = propertyData.map { value in
                var column:String = value.name!
                if value.isClass{
                    if let sub = value.value as? Reflect {
                        dataArgs.append(sub.objectId!.int64Value)
                        column = "\(type(of: sub).entityName())_objectId"
                    }
                }
                else{
                    dataArgs.append(value.value as? Value)
                }
                placeholder.append("?")
                return column
                }.joined(separator: ", ")
            
            /* Columns to be inserted */
            statement += " ( \(columns) ) VALUES (" + placeholder.joined(separator: ", ") + ")"
            return (statement, dataArgs)
            
        case .update(var object):
            var statement = "UPDATE \(T.entityName()) SET"
            object.updatedAt = Date()
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId" , "createdAt"])
            
            var dataArgs:[Value?] = []
            let columns = propertyData.map { value in
                var column:String = "\(value.name!) = ?"
                if value.isClass{
                    if let sub = value.value as? Reflect {
                        dataArgs.append(sub.objectId!.int64Value)
                        column = "\(type(of: sub).entityName())_objectId = ?"
                    }
                }
                else{
                    dataArgs.append(value.value as? Value)
                }
                return column
                }.joined(separator: ", ")
            
            dataArgs.append(object.objectId!.int64Value)
            statement += " \(columns) WHERE objectId = ?"
            
            return (statement, dataArgs)
            
        case .delete(let object):
            let comp = object.objectId == nil ? "" : " WHERE objectId = ?"
            return ("DELETE FROM \(T.entityName())" + comp , comp.isEmpty ? [] : [object.objectId!.int64Value])
        }
    }
}
