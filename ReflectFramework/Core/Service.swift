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
    
    func create(obj:AnyObject) throws {
        let p:[MirrorModel] = Mirror.refectObject(obj)
        table = (obj as! T).dynamicType.tableName()
        try db.execute(Schema.Create(table,p).sql)
    }
    
    func destroy() throws {
        try db.execute(Schema.Drop(table).sql)
    }
    
    func fetchOne(obj:AnyObject, id: Int) {
        if checkRegister() {
            let schema = Schema.Select(table, id)
//            let row = db.prepareFetch(schema.sql, id)!
//            let p:[MirrorModel] = Mirror.refectObject(obj)
//    
//            for property in p {
//                let key = property["key"] as! String
//                let type = property["type"] as! String
//                if let value = castDataValue(key ,type: type, row: obj) {
//                    base.setValue(value, forKey: key)
//                }
//            }
            
        }
    }
    
    func insert(obj:AnyObject) throws -> Int {
        if checkRegister() {
            let p:[MirrorModel] = Mirror.refectObject(obj)
            let schema = Schema.Insert(table, p)
            return Int(try db.runRowId(schema.sql, schema.args))
        }
        return -1
    }
    
    func upsert() -> Bool {
        return false
    }
    
    func delete(id: Int) throws -> Int {
        if checkRegister() {
            let schema = Schema.Delete(table, id)
            return try db.runChange(schema.sql, id)
        }
        return -1
    }
    
    func delete() throws -> Int {
        if checkRegister() {
            let schema = Schema.Delete(table , 0)
            return try db.runChange(schema.sql)
        }
        return -1
    }
    
    /*
    // MARK: - Private Methods
    */
    
    private func checkRegister() -> Bool {
        if table == nil {
            assertionFailure("This object wasn't registed")
        }
        return table != nil
    }
    
    private func castDataValue(key:String, type:String, row:Row) -> AnyObject! {
        
        switch type {
        case String.declaredDatatype:
            return row[key , String.self]
        case Int.declaredDatatype:
            return row[key , Int.self]
        case Double.declaredDatatype:
            return row[key , Double.self]
        case Float.declaredDatatype:
            return row[key , Float.self]
        case NSNumber.declaredDatatype:
            return row[key , NSNumber.self]
        case Bool.declaredDatatype:
            return row[key , Bool.self]
        case NSDate.declaredDatatype:
            return row[key , NSDate.self]
        case NSData.declaredDatatype:
            return row[key , NSData.self]
        default:
            return nil
        }
        
    }
    
}
