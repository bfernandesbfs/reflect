//
//  Schema.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

enum Schema {
    private static let identifier:String = "id"
    
    case Create(String, [MirrorModel])
    case Drop(String)
    case Select(String)
    case Insert(String, [MirrorModel])
    case Update(String, Int, [MirrorModel])
    case Delete(String, Int)
    
    var sql: String {
        switch self {
        case .Create(let className,let properties):
            return "CREATE TABLE IF NOT EXISTS \(className) (\(Schema.identifier) INTEGER PRIMARY KEY AUTOINCREMENT \(createSql(properties)))"
        case .Drop(let className):
            return "DROP TABLE \(className)"
        case .Select(let className):
            return "SELECT * FROM \(className) WHERE \(Schema.identifier) = ?"
        case .Insert(let className,let properties):
            return "INSERT INTO \(className) (\(generateInsert(properties)))"
        case .Update(let className,_ ,let properties):
            return "UPDATE \(className) SET \(generateUpdate(properties)) WHERE \(Schema.identifier) = ?"
        case .Delete(let className , let objectId):
            let comp = objectId == 0 ? "" : " WHERE \(Schema.identifier) = ?"
            return "DELETE FROM \(className)" + comp
        }
    }
    
    var args:[AnyObject?] {
        switch self {
        case .Update(_, let id, var properties):
            properties.append(MirrorModel(key:Schema.identifier, value: id, type: Int.declaredDatatype))
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
    
    private func generateInsert(properties:[MirrorModel]) -> String {
        
        var fields:String = ""
        var values:String = "VALUES ( "
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
    
    private func generateUpdate(properties:[MirrorModel]) -> String {
        
        var values:String = ""
        var isFirst = true
        
        for property in properties {
            
            if isFirst {
                isFirst = false
                values += "\(property.key) = ?"

            } else {
                values += ", \(property.key) = ?"
            }
            
        }
        return values
    }

}
