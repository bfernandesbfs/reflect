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
    case Insert(T)
    case Update(T)
    case Delete(T)
    
    var statement: (sql:String, args:[AnyObject?]) {
        switch self {
        case .Create(let object):
            
            let tableName =  T.entityName()
            var statement = "CREATE TABLE IF NOT EXISTS " + tableName + " ("
            var fields:[String] = []
            
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId"])
            statement += "objectId INTEGER PRIMARY KEY AUTOINCREMENT, "
            let _ = propertyData.map { value in
                var data = "\(value.name!) \(SchemaType(type: value.type!)!.rawValue)"
                data += value.isOptional ? "" : " NOT NULL"
                fields.append(data)
            }
            
            statement += fields.joinWithSeparator(", ")
            
            if T.self is FieldsProtocol.Type {
                let fieds = T.self as! FieldsProtocol.Type
                if !fieds.primaryKeys().isEmpty {
                    statement += ", PRIMARY KEY (\(fieds.primaryKeys().joinWithSeparator(", ")))"
                }
            }
            
            statement += ")"
        
            return (statement, [])
            
        case .Drop(let tableName):
            return ("DROP TABLE \(tableName)" , [])
            
        case .Insert(var object):
            var statement = "INSERT OR REPLACE INTO " + T.entityName()
            object.createAt = NSDate()
            object.updateAt = object.createAt
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId"])
            
            var dataArgs:[AnyObject?] = []
            var placeholder:[String] = []
            let columns = propertyData.map { value in
                dataArgs.append(value.value)
                placeholder.append("?")
                return value.name!
                }.joinWithSeparator(", ")
            
            /* Columns to be inserted */
            statement += " ( \(columns) ) VALUES (" + placeholder.joinWithSeparator(", ") + ")"
            return (statement, dataArgs)
            
        case .Update(var object):
            var statement = "UPDATE \(T.entityName()) SET"
            object.updateAt = NSDate()
            let propertyData = ReflectData.validPropertyDataForObject(object, ignoredProperties: ["objectId" , "createAt"])
            
            var dataArgs:[AnyObject?] = []
            let columns = propertyData.map { value in
                dataArgs.append(value.value)
                return "\(value.name!) = ?"
                }.joinWithSeparator(", ")
            
            dataArgs.append(object.objectId)
            statement += " \(columns) WHERE objectId = ?"
            
            return (statement, dataArgs)
            
        case .Delete(let object):
            let comp = object.objectId == nil ? "" : " WHERE objectId = ?"
            return ("DELETE FROM \(T.entityName())" + comp , comp.isEmpty ? [] : [object.objectId!])
        }
    }
    
}

internal enum SchemaType: String {
    case Text       = "TEXT"
    case Integer    = "INTEGER"
    case Real       = "REAL"
    case Date       = "DATE"
    case Blob       = "BLOB"
    case Numeric    = "NUMERIC"
    case Null       = "NULL"
    
    init?(type: Any.Type) {
        switch type {
        case is Int.Type, is Int8.Type, is Int16.Type, is Int32.Type, is Int64.Type, is UInt.Type, is UInt8.Type, is UInt16.Type, is UInt32.Type, is UInt64.Type, is Bool.Type:
            self.init(rawValue: "INTEGER")
        case is Double.Type, is Float.Type:
            self.init(rawValue: "REAL")
        case is NSDate.Type:
            self.init(rawValue: "DATE")
        case is NSData.Type:
            self.init(rawValue: "BLOB")
        case is NSNumber.Type:
            self.init(rawValue: "NUMERIC")
        case is String.Type, is NSString.Type, is Character.Type:
            self.init(rawValue: "TEXT")
        default:
            fatalError("Error object not supported")
        }
    }
}
