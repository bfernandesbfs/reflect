//
//  Query.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

import Foundation

public class Query<T where T:ReflectProtocol> {
    public typealias Handler = (query: Query) -> Query
    
    public var dataArgs:[Value?]
    
    private var dataDistinct :Bool
    private var dataAggregate:Aggregate
    private var dataFields  :[String]
    private var dataUnion   :[Filter]
    private var dataClause  :[Filter]
    private var dataOrder   :[Filter]
    private var dataPage    :[Pagination]
    private var entity: String {
        return T.entityName()
    }
    
    var statement:(sql:String, args:[Value?]) {
        var query: [String] = [resolveSelect()]
        if dataClause.count == 0 {
            return (query.first!, [])
        }
        //JOIN
        if dataUnion.count > 0 {
            var filterUnion: [String] = []
            for filter in dataUnion {
                filterUnion.append(filterOutput(filter))
            }
            query.append(filterUnion.joinWithSeparator(" "))
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
        dataDistinct  = false
        dataAggregate = Aggregate.Default
        dataFields   = []
        dataUnion    = []
        dataClause   = []
        dataArgs     = []
        dataOrder    = []
        dataPage     = []
    }
    
    public func fields(key:String...) -> Self {
        dataFields += key
        return self
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
    
    public func join<T: ReflectProtocol>(type: T.Type, _ operation: Join = .Inner, foreignKey: String? = nil, _ comparison: Comparison = .Equals, otherKey: String? = nil ,alias:String = "" ) -> Self? {
        let fk = foreignKey ?? "\(entity).\(type.entityName())_objectId"
        let ok = otherKey ?? "\(type.entityName()).objectId"
        let union = Filter.Union(operation, type.entityName(), fk, comparison, ok)
        dataUnion.append(union)
        createFieldsAlias(type,alias: alias)
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
    
    public func distinct() -> Self {
        dataDistinct = true
        return self
    }
    
    public func count(field: String = "*") -> Double {
        dataAggregate = Aggregate.Count(field)
        return aggregateObject(dataAggregate.field)
    }
    
    public func average(field: String = "*") -> Double {
        dataAggregate = Aggregate.Average(field)
        return aggregateObject(dataAggregate.field)
    }
    
    public func max(field: String = "*") -> Double {
        dataAggregate = Aggregate.Max(field)
        return aggregateObject(dataAggregate.field)
    }
    
    public func min(field: String = "*") -> Double {
        dataAggregate = Aggregate.Min(field)
        return aggregateObject(dataAggregate.field)
    }
    
    public func sum(field: String = "*") -> Double {
        dataAggregate = Aggregate.Sum(field)
        return Double(aggregateObject(dataAggregate.field))
    }
    
    public func findObject() -> [T] {
        return try! Driver().find(self)
    }
    
}

private extension Query {
    /*
    // MARK: - Private Methods
    */
    
    private func resolveSelect() -> String {
        var select = ["SELECT"]
        if dataDistinct {
            select.append("DISTINCT")
        }
        
        if dataFields.count > 0 && dataAggregate.field == Aggregate.Default.field {
            dataFields.append("\(entity).*")
            select.append(dataFields.joinWithSeparator(", "))
        } else {
            select.append(dataAggregate.description)
        }
        
        select.append("FROM \(entity)")
        
        return select.joinWithSeparator(" ")
    }
    
    private func createFieldsAlias<T: ReflectProtocol>(type: T.Type, alias:String) {
        let properties = ReflectData.validPropertyDataForObject(type.init())
        let namespace  = alias.isEmpty ? type.entityName() : alias
        let columns = properties.map { value in
            return "\(namespace).\(value.name!) AS '\(namespace).\(value.name!)'"
        }
        dataFields += columns
    }
    
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
        case .Union(let join, let entity, let fk, let comparison, let ok):
            return "\(join.description) \(entity) ON \(fk) \(comparison.description) \(ok)"
        }
    }
    
    private func aggregateObject(field:String) -> Double {
        if let value = try! Driver().find(self, column: field) {
            if let v = value as? Int64 {
                return Double(v)
            }
            else if let v = value as? Double {
                return v
            }
            else if let v = value as? Float {
                return Double(v)
            }
        }
        return 0
    }
}