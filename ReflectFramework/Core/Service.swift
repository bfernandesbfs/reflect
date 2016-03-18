//
//  Service.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

class  Service<T: Initable> : Driver {
    
    var table:String!
    
    init(){
    }
    
    func create(obj:AnyObject){
        let p:[MirrorModel] = Mirror.refectObject(obj)
        table = (obj as! T).dynamicType.tableName()
        let scheme = Schema.Create(table,p)
        print("REGISTER", scheme.sql , scheme.args)
    }
    
    func destroy(){
        let scheme = Schema.Drop(table)
        print("DESTROY", scheme.sql)
    }
    
    func fetchOne(id: Int) {
        if checkRegister() {
            let scheme = Schema.Select(table, id)
            print("FECH" , scheme.sql , scheme.args, id)
        }
    }
    
    func insert(obj:AnyObject) -> Bool {
        if checkRegister() {
            let p:[MirrorModel] = Mirror.refectObject(obj)
            let scheme = Schema.Insert(table, p)
            print("ADD", scheme.sql, scheme.args)
            return true
        }
        return false
    }
    
    func upsert() -> Bool {
        return false
    }
    
    func delete(id: Int) -> Bool {
        if checkRegister() {
            let scheme = Schema.Delete(table, id)
            print("DELETE" , scheme.sql , scheme.args, id)
            return true
        }
        return false
    }
    
    private func checkRegister() -> Bool {
        if table == nil {
            assertionFailure("This object wasn't registed")
        }
        return table != nil
    }
}
