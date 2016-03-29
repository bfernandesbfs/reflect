//
//  Drive.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 28/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public class Driver<T :ReflectProtocol>: DriverProtocol {
    
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

}

extension Driver {
    
    public func objectsForType<T where T: ReflectProtocol, T: NSObject>(object: T, row: Row) {
        let propertyData = ReflectData.validPropertyDataForObject(object)
        for property in propertyData {
            if let value = bindValue(property, row: row) {
                object.setValue(value, forKey: property.name!)
            }
        }
    }
    
    private func bindValue(property:ReflectData , row:Row) -> AnyObject! {
        
        switch property.type {
        case is String.Type:
            return row[property.name! , String.self]
        case is Int.Type:
            return row[property.name! , Int.self]
        case is Double.Type:
            return row[property.name! , Double.self]
        case is Float.Type:
            return row[property.name! , Float.self]
        case is NSNumber.Type:
            let v = row[property.name! , Int.self]
            return NSNumber(integer: v)
        case is Bool.Type:
            return row[property.name! , Bool.self]
        case is NSDate.Type:
            return row[property.name! , NSDate.self]
        case is NSData.Type:
            return row[property.name! , NSData.self]
        default:
            return nil
        }
        
    }
}