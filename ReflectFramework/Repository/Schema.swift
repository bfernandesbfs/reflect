//
//  Schema.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

enum Schema {
    private static let indentifier:String = "id"
    
    case Create(String, [MirrorModel])
    case Drop(String)
    case Select(String)
    case Replace(String, Int, [MirrorModel])
    case Insert(String, [MirrorModel])
    case Delete(String, Int)
    
    var sql: String {
        switch self {
        case .Create(let className,let properties):
            return "CREATE TABLE IF NOT EXISTS \(className) (\(Schema.indentifier) INTEGER PRIMARY KEY AUTOINCREMENT \(createSql(properties)))"
        case .Drop(let className):
            return "DROP TABLE \(className)"
        case .Select(let className):
            return "SELECT * FROM \(className) WHERE \(Schema.indentifier) = ?"
        case .Replace(let className, _, let properties):
            return "INSERT OR REPLACE INTO \(className) (\(saveSql(true, properties: properties)))"
        case .Insert(let className,let properties):
            return "INSERT INTO \(className) (\(saveSql(false,properties: properties)))"
        case .Delete(let className , let objectId):
            let comp = objectId == 0 ? "" : " WHERE \(Schema.indentifier) = ?"
            return "DELETE FROM \(className)" + comp
        }
    }
    
    var args:[AnyObject?] {
        switch self {
        case .Replace(_,let objectId, var properties):
            properties.append(MirrorModel(key:Schema.indentifier, value: objectId, type: Int.declaredDatatype))
            return MirrorModel.getValues(properties)
        case .Insert(_,let properties):
            return MirrorModel.getValues(properties)
        default:
            return []
        }
    }
    
    private func createSql(properties:[MirrorModel]) -> String {
        var fields:String = String()
        for property in properties {
            fields += ", \(property.key) \(property.type)"
        }
        return fields
    }
    
    private func saveSql(isReplace:Bool, properties:[MirrorModel]) -> String {
        
        var fields:String = isReplace ? "\(Schema.indentifier), " : ""
        var values:String = isReplace ? "VALUES ( ?, " : "VALUES ( "
        var isFirst = true
        
        for property in properties {
            
            if isFirst {
                isFirst = false
                fields += "\(property.key)"
                values += "?"
                
            } else {
                fields += ", \(property.key)"
                values += ", ?"
            }
            
        }
        return fields + ") \(values)"
    }
}
