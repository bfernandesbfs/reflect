//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public class Driver<T where T:ReflectProtocol>: DriverProtocol {
    
    private lazy var db: Connection = {
        let path = Reflect.settings.createPath()
        return try! Connection(path)
    }()
    
    public func create(obj: T.Type) throws {
        let rft = obj.init()
        let schema = Schema.Create(rft)
        try db.execute(schema.statement.sql)
    }
    
    public func drop(obj: T.Type) throws {
        let schema = Schema<T>.Drop(T.entityName())
        try db.execute(schema.statement.sql)
    }
    
    public func removeAll(obj: T.Type) throws {
        let rft = obj.init()
        try db.runChange(Schema.Delete(rft))
    }
    
    public func save(obj: T) throws {
        var rft = obj
        if rft.objectId == nil {
            let rowId = try db.runRowId(Schema.Insert(rft))
            rft.objectId = NSNumber(longLong: rowId)
        }
        else{
            try change(obj)
        }
    }
    
    public func change(obj: T) throws -> Int {
        return Int(try db.runChange(Schema.Update(obj)))
    }
    
    public func delete(obj: T) throws -> Int {
        return try db.runChange(Schema.Delete(obj))
    }
    
    public func fetch(obj: T) throws {
        let q = Query<T>().filter("objectId", Comparison.Equals, value: obj.objectId!)
        if let row = try db.prepareFetch(q) {
            objectsForType(obj as! Reflect, row: row)
        }
        else{
            throw Result.Error(message: "Not found", code: 1001, statement: nil)
        }
    }
    
    public func find(id: Int) throws -> T? {
        var rft = T()
        rft.objectId = id
        try fetch(rft)
        return rft
    }
    
    public func find(query: Query<T>) throws -> [T] {
        
        var results:[T] = []
        for row in try db.prepareQuery(query)! {
            let obj:T = T()
            objectsForType(obj as! Reflect, row: row)
            results.append(obj)
        }
        return results
    }
    
    public func find(query: String) throws -> [[String: Value?]] {
        
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
    
    public func find(query: Query<T>, column:String) throws -> Value? {
        if let row = try db.prepareFetch(query) {
            return row[column].asValue()
        }
        return nil
    }

}

extension Driver {
    
    private func objectsForType<T where T: ReflectProtocol, T: NSObject>(object: T, row: Row) {

        let propertyData = ReflectData.validPropertyDataForObject(object)
        for property in propertyData {
            if property.isClass {
                if let sub = property.type as? Reflect.Type {
                    let objectSub = sub.init()
                    let propertyDataSub = ReflectData.validPropertyDataForObject(objectSub)
                    for propertySub in propertyDataSub {
                        let column = "\(sub.entityName()).\(propertySub.name!)"
                        if let value = bindValue(propertySub.type, column: column,  row: row) {
                            objectSub.setValue(value, forKey: propertySub.name!)
                        }
                    }
                    object.setValue(objectSub, forKey: property.name!)
                }
                
            }
            else{
                if let value = bindValue(property.type, column: property.name!, row: row) {
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