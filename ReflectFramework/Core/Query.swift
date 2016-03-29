//
//  Query.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public class Query<T :ReflectProtocol>{
    typealias Handler = (query: Query) -> Query
    
    var dataArgs:[AnyObject?]
    
    private var dataClause:[Filter]
    
    var statement:(sql:String, args:[AnyObject?]) {
        let entity = T.entityName()
        if dataClause.count == 0 {
            return ("SELECT * FROM \(entity)", [])
        }
        
        var filterClause: [String] = []
        for filter in dataClause {
            filterClause.append(filterOutput(filter))
        }
        
        return ("SELECT * FROM \(entity) WHERE " + filterClause.joinWithSeparator(" AND ") , dataArgs)
    }
    
    init(){
        dataClause = []
        dataArgs   = []
    }
    
    func filter(key:String, _ comparison: Comparison, value:AnyObject...) -> Self {
        if value.count > 1 {
            dataClause.append(Filter.Subset(key, comparison, value))
        }
        else{
            dataClause.append(Filter.Compare(key, comparison, value.first!))
        }
        return self
    }
    
    func or(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.Or, q.dataClause)
        dataClause.append(filter)
        return self
    }
    
    func and(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.And, q.dataClause)
        dataClause.append(filter)
        return self
    }
    
    func findObject() -> [T] {
        return try! Driver().find(self)
    }
    
    /*
    // MARK: - Private Methods
    */
    private func filterOutput(filter: Filter) -> String {
        switch filter {
        case .Compare(let field, let comparison, let value):
            dataArgs.append(value)
            return "\(field) \(comparison.description) ?"
        case .Subset(let field, let scope, let values):
            let valueDescriptions = values.map { value in
                dataArgs.append(value)
                return "?"
                }.joinWithSeparator(" , ")
            return "\(field) \(scope) (\(valueDescriptions))"
        case .Group(let op, let filters):
            let f: [String] = filters.map {
                if case .Group = $0 {
                    return self.filterOutput($0)
                }
                return "\(self.filterOutput($0))"
            }
            return "(" + f.joinWithSeparator(" \(op.description) ") + ")"
        }
    }
}