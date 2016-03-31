//
//  Query.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public class Query<T :ReflectProtocol>{
    public typealias Handler = (query: Query) -> Query
    
    public var dataArgs:[Value?]
    
    private var dataClause:[Filter]
    private var dataOrder :[Filter]
    private var dataPage  :[Pagination]
    
    var statement:(sql:String, args:[Value?]) {
        let entity = T.entityName()
        var query: [String] = ["SELECT * FROM \(entity)"]
        if dataClause.count == 0 {
            return (query.first!, [])
        }
    
        //Where
        var filterClause: [String] = []
        for filter in dataClause {
            filterClause.append(filterOutput(filter))
        }
        query.append("WHERE \(filterClause.joinWithSeparator(" AND "))")
        
        //Order by
        if dataOrder.count > 0 {
            query.append("ORDER BY")
            var filterOrder: [String] = []
            for order in dataOrder {
                filterOrder.append(filterOutput(order))
            }
            query.append(filterOrder.joinWithSeparator(", "))
        }
        //Limit and Offset
        for page in dataPage {
            query.append(page.description)
        }
        
        let x = ("\(query.joinWithSeparator(" "));" , dataArgs)
        print(x.0)
        return ("\(query.joinWithSeparator(" "));" , dataArgs)
    }
    
    public init(){
        dataClause = []
        dataArgs   = []
        dataOrder  = []
        dataPage   = []
    }
    
    public func filter(key:String, _ comparison: Comparison, value:Value?...) -> Self {
        if value.count > 1 {
            dataClause.append(Filter.Subset(key, comparison, value))
        }
        else{
            dataClause.append(Filter.Compare(key, comparison, value.first!))
        }
        return self
    }
    
    public func or(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.Or, q.dataClause)
        dataClause.append(filter)
        return self
    }
    
    public func and(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.And, q.dataClause)
        dataClause.append(filter)
        return self
    }
    
    public func sort(field: String, _ direction: Sort) -> Self {
        let order = Filter.Order(field, direction)
        dataOrder.append(order)
        return self
    }
    
    public func limit(count: Int = 1) -> Self {
        dataPage.append(Pagination.Limit(count))
        return self
    }
    
    public func offset(count: Int = 1) -> Self {
        dataPage.append(Pagination.Offset(count))
        return self
    }
    
    public func findObject() -> [T] {
        return try! Driver().find(self)
    }
    
}

extension Query {
    /*
    // MARK: - Private Methods
    */
    private func filterOutput(filter: Filter) -> String {
        switch filter {
        case .Compare(let field, let comparison, let value):
            if value == nil {
                return "\(field) \(comparison.description) NULL"
            }
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
        case .Order(let field, let order):
            return "\(field) \(order)"
        }
    }
}