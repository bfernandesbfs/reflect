//
//  Schema.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public enum Schema<T: ReflectProtocol> {
    
    case Create(T)
    case Drop(String)
    case Index(entity:String, field: String , unique: Bool)
    case DropIndex(entity:String, field: String)
    case Insert(T)
    case Update(T)
    case Delete(T)
    
    var statement: (sql:String, args:[Value?]) {
        switch self {
        case .Create(let object):
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

            statement += "\(fields.joinWithSeparator(", ")))"
        
            return (statement, [])
        
        case .Drop(let tableName):
            return ("DROP TABLE \(tableName)" , [])
            
        case .Index(let entityName, let field , let unique):
            var statement = unique ? "CREATE UNIQUE INDEX" : "CREATE INDEX"
            statement += " IF NOT EXISTS index_\(entityName)_on_\(field) ON \(entityName) (\(field))"
            
            return (statement , [])
        
        case .DropIndex(let entityName, let field):
            var statement = "DROP INDEX"
            statement += " IF EXISTS index_\(entityName)_on_\(field)"

            return (statement , [])
            
        case .Insert(var object):
            var statement = "INSERT INTO " + T.entityName()
            object.createdAt = NSDate()
            object.updatedAt = object.createdAt
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId"])
            
            var dataArgs:[Value?] = []
            var placeholder:[String] = []
            let columns = propertyData.map { value in
                var column:String = value.name!
                if value.isClass{
                    if let sub = value.value as? Reflect {
                        dataArgs.append(sub.objectId!.longLongValue)
                        column = "\(sub.dynamicType.entityName())_objectId"
                    }
                }
                else{
                    dataArgs.append(value.value as? Value)
                }
                placeholder.append("?")
                return column
                }.joinWithSeparator(", ")
            
            /* Columns to be inserted */
            statement += " ( \(columns) ) VALUES (" + placeholder.joinWithSeparator(", ") + ")"
            return (statement, dataArgs)
            
        case .Update(var object):
            var statement = "UPDATE \(T.entityName()) SET"
            object.updatedAt = NSDate()
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId" , "createdAt"])
            
            var dataArgs:[Value?] = []
            let columns = propertyData.map { value in
                var column:String = "\(value.name!) = ?"
                if value.isClass{
                    if let sub = value.value as? Reflect {
                        dataArgs.append(sub.objectId!.longLongValue)
                        column = "\(sub.dynamicType.entityName())_objectId = ?"
                    }
                }
                else{
                    dataArgs.append(value.value as? Value)
                }
                return column
                }.joinWithSeparator(", ")
            
            dataArgs.append(object.objectId!.longLongValue)
            statement += " \(columns) WHERE objectId = ?"
            
            return (statement, dataArgs)
            
        case .Delete(let object):
            let comp = object.objectId == nil ? "" : " WHERE objectId = ?"
            return ("DELETE FROM \(T.entityName())" + comp , comp.isEmpty ? [] : [object.objectId!.longLongValue])
        }
    }
}
