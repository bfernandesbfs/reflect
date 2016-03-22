//
//  Query.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

class Query<T: Initable>{
    typealias Handler = (query: Query) -> Query
    
    private var dataClause:[Filter]
    private var nextPlaceholder: String {
        return "?"
    }
    
    init(){
        dataClause = []
    }
    
    func filter(key:String, _ comparison: Comparison, value:String...) -> Self {
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
    
    func query() -> [T]? {
        
        if dataClause.count == 0 {
            return nil
        }
        
        var filterClause: [String] = []
        for filter in dataClause {
            filterClause.append(filterOutput(filter))
        }
        
        let q = "WHERE " + filterClause.joinWithSeparator(" AND ")
        print(q)
        return []
    }
    
    
    /*
    // MARK: - Private Methods
    */
    private func filterOutput(filter: Filter) -> String {
        switch filter {
        case .Compare(let field, let comparison,_):
            return "\(field) \(comparison.description) \(nextPlaceholder)"
        case .Subset(let field, let scope, let values):
            let valueDescriptions = values.map { value in
                return nextPlaceholder
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