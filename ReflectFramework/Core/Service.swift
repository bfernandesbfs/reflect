//
//  Service.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

class  Service<T: Initable> : Driver {
    
    private var table:String!
    private lazy var db: Connection = {
        let path = Reflect.settings.createPath()
        return try! Connection(path)
    }()
    
    func create(obj:Reflect) throws {
        let p:[MirrorModel] = Mirror.refectObject(obj)
        table = obj.dynamicType.tableName()
        try db.execute(Schema.Create(table,p).sql)
    }
    
    func destroy() throws {
        try db.execute(Schema.Drop(table).sql)
    }
    
    func find<T>(obj:Reflect, id: Int) throws -> T? {
        try checkRegister()
        obj.id = id
        try fetch(obj)
        return obj as? T
    }
    
    func fetch(obj:Reflect) throws {
        try checkRegister()
        let schema = Schema.Select(table)
        if let row = try db.prepareFetch(schema.sql, obj.id) {
            for property in Mirror.refectObject(obj) {
                if let value = bindValue(property, row: row) {
                    obj.setValue(value, forKey: property.key)
                }
            }
        }
        else{
            throw Result.Error(message: "Not found", code: 1001, statement: nil)
        }
    }
    
    func insert(obj:Reflect) throws -> Int {
        try checkRegister()
        let p:[MirrorModel] = Mirror.refectObject(obj)
        let schema :Schema!
        if  obj.id > 0 {
            schema = Schema.Update(table, obj.id!, p)
            return Int(try db.runChange(schema.sql, schema.args))
        }
        else {
            schema = Schema.Insert(table, p)
            return Int(try db.runRowId(schema.sql, schema.args))
        }
    }
    
    func upsert() -> Bool {
        return false
    }
    
    func delete(id: Int) throws -> Int {
        try checkRegister()
        let schema = Schema.Delete(table, id)
        return try db.runChange(schema.sql, id)
    }
    
    func delete() throws -> Int {
        try checkRegister()
        let schema = Schema.Delete(table , 0)
        return try db.runChange(schema.sql)
    }
    
    /*
    // MARK: - Private Methods
    */
    
    private func checkRegister() throws -> Bool {
        if table == nil {
            throw Result.Error(message: "This object wasn't registed", code: 1000, statement: nil)
        }
        return table != nil
    }
    
    private func bindValue(property:MirrorModel, row:Row) -> AnyObject! {
        
        switch property.type {
        case String.declaredDatatype:
            return row[property.key , String.self]
        case Int.declaredDatatype:
            return row[property.key , Int.self]
        case Double.declaredDatatype:
            return row[property.key , Double.self]
        case Float.declaredDatatype:
            return row[property.key , Float.self]
        case NSNumber.declaredDatatype:
            return row[property.key , NSNumber.self]
        case Bool.declaredDatatype:
            return row[property.key , Bool.self]
        case NSDate.declaredDatatype:
            return row[property.key , NSDate.self]
        case NSData.declaredDatatype:
            return row[property.key , NSData.self]
        default:
            return nil
        }
        
    }
    
}
