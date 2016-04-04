//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

internal class Driver<T where T:ReflectProtocol>: DriverProtocol {
    
    private lazy var db: Connection = {
        let path = Reflect.settings.createPath()
        return try! Connection(path)
    }()
    
    internal func create(obj: T.Type) throws {
        let rft = obj.init()
        let schema = Schema.Create(rft)
        try db.execute(schema.statement.sql)
    }
    
    internal func drop(obj: T.Type) throws {
        let schema = Schema<T>.Drop(T.entityName())
        try db.execute(schema.statement.sql)
    }
    
    internal func index(obj:T.Type, field: String, unique: Bool = false) throws {
        let schema = Schema<T>.Index(entity: obj.entityName(), field: field, unique: unique)
        try db.run(schema)
    }
    
    internal func dropIndex(obj: T.Type, field: String) throws {
        let schema = Schema<T>.DropIndex(entity: T.entityName(), field: field)
        try db.run(schema)
    }
    
    internal func removeAll(obj: T.Type) throws {
        let rft = obj.init()
        try db.runChange(Schema.Delete(rft))
    }
    
    internal func save(obj: T) throws {
        var rft = obj
        if rft.objectId == nil {
            let rowId = try db.runRowId(Schema.Insert(rft))
            rft.objectId = NSNumber(longLong: rowId)
        }
        else{
            try change(obj)
        }
    }
    
    internal func change(obj: T) throws -> Int {
        return Int(try db.runChange(Schema.Update(obj)))
    }
    
    internal func delete(obj: T) throws -> Int {
        return try db.runChange(Schema.Delete(obj))
    }
    
    internal func fetch(obj: T, include:[Any.Type] = []) throws {
        let q = Query<T>().filter("\(T.entityName()).objectId", Comparison.Equals, value: obj.objectId!)
        
        for k in include {
            if let sub = k as? Reflect.Type {
                q.join(sub)
            }
        }
        
        if let row = try db.prepareFetch(q) {
            objectsForType(obj as! Reflect, row: row)
        }
        else{
            throw Result.Error(message: "Not found", code: 1001, statement: nil)
        }
    }
    
    //Find by Id
    internal func find(id: Int, include:[Any.Type] = []) throws -> T? {
        var rft = T()
        rft.objectId = id
        try fetch(rft, include: include)
        return rft
    }
    
    //Find Query
    internal func find(query: Query<T>) throws -> [T] {
        
        var results:[T] = []
        for row in try db.prepareQuery(query)! {
            let obj:T = T()
            objectsForType(obj as! Reflect, row: row)
            results.append(obj)
        }
        return results
    }
    
    //Find String Reflect
    internal func find(query: String) throws -> [[String: Value?]] {
        
        var results:[[String: Value?]] = []
        for (index ,row) in try db.prepareQuery(query)!.enumerate() {
            var item:[String: Value?] = [:]
            for names in row[index] {
                item[names] = row[names].asValue()
            }
        
            results.append(item)
        }
        return results
    }
    
    //Find Aggregate
    internal func find(query: Query<T>, column:String) throws -> Value? {
        if let row = try db.prepareFetch(query) {
            return row[column].asValue()
        }
        return nil
    }

}

private extension Driver {
    
    private func objectsForType<T where T: ReflectProtocol, T: NSObject>(object: T, row: Row, alias:String = "") {
        
        let propertyData = ReflectData.validPropertyDataForObject(object)
        for property in propertyData {
            if property.isClass {
                if let sub = property.type as? Reflect.Type {
                    let objectSub = sub.init()
                    objectsForType(objectSub, row: row, alias: "\(sub.entityName()).")
                    object.setValue(objectSub, forKey: property.name!)
                }
            }
            else{
                let column = "\(alias)\(property.name!)"
                if let value = bindValue(property.type, column: column, row: row) {
                    object.setValue(value, forKey: property.name!)
                }
            }
        }
    }
    
    private func bindValue(type: Any.Type?, column:String, row:Row) -> AnyObject? {
        if row[column] {
            switch type {
            case is String.Type, is NSString.Type:
                return row[column].asString()
            case is Int.Type, is Int8.Type, is Int16.Type, is Int32.Type:
                return row[column].asInt()
            case is UInt.Type, is UInt8.Type, is UInt16.Type, is UInt32.Type:
                return row[column].asInt()
            case is Int64.Type, is UInt64.Type:
                return row[column].asInt()
            case is Double.Type:
                return row[column].asDouble()
            case is Float.Type:
                return row[column].asFloat()
            case is Bool.Type:
                return row[column].asBool()
            case is NSNumber.Type:
                return row[column].asNumber()
            case is NSDate.Type:
                return row[column].asDate()
            case is NSData.Type:
                return row[column].asData()
            default:
                return nil
            }
        }
        return nil
    }
}