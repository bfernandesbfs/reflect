//
//  Query.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

/// Query 
//  Controla a criação dos filtros para gerar o sql text and argumentos 
//  para acessar oos dados no Data Base
public class Query<T where T:ReflectProtocol> {
    /// Alias Handlee para clauses AND and OR
    public typealias Handler = (query: Query) -> Query
    /// Argumentos to Query
    public var dataArgs:[Value?]
    /// Distinct values
    private var dataDistinct :Bool
    /// Aggregate value (COUNT, SUM, MAX, MIN and AVG)
    private var dataAggregate:Aggregate
    /// Information to Fieds
    private var dataFields  :[String]
    /// Join beetween Reflect object
    private var dataUnion   :[Filter]
    /// Filters
    private var dataClause  :[Filter]
    /// Order by objects
    private var dataOrder   :[Filter]
    /// Limit and Offset
    private var dataPage    :[Pagination]
    /// Entity name
    private var entity: String {
        return T.entityName()
    }
    
    /// Statement Sql contem intrução sql and argumentos
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
        return ("\(query.joinWithSeparator(" "));" , dataArgs)
    }
    /**
     Initialize Object
     
     */
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
    /**
     Selecione column
     
     - parameter key: Column names
     
     - returns: Self
     */
    public func fields(key:String...) -> Self {
        dataFields += key
        return self
    }
    /**
     Basic Filter - Atribui condição AND , merge od filtros com AND
     
     - parameter key:        Column name
     - parameter comparison: Comparison option
     - parameter value:      value to filter
     
     - returns: Self
     */
    public func filter(key:String, _ comparison: Comparison, value:Value?...) -> Self {
        if value.count > 1 {
            dataClause.append(Filter.Subset(key, comparison, value))
        }
        else{
            dataClause.append(Filter.Compare(key, comparison, value.first!))
        }
        return self
    }
    /**
     Or Filter - Create an block  with condição OR para as confinações de filtro especifico with OR
     
     - parameter handler: Block Handler
     
     - returns: Self
     */
    public func or(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.Or, q.dataClause)
        dataClause.append(filter)
        return self
    }
    /**
     And Filter -  Create an block with condição AND para as confinaç~eos de filtro especifico with OR
     
     - parameter handler: Block Handler
     
     - returns: Self
     */
    public func and(handler: Handler) -> Self {
        let q = handler(query: Query())
        let filter = Filter.Group(.And, q.dataClause)
        dataClause.append(filter)
        return self
    }
    /**
     Join Filter Class
     
     - parameter type:       Reflect Object
     - parameter operation:  Join option
     - parameter foreignKey: Column name to entity
     - parameter comparison: Comparison option
     - parameter otherKey:   Column name to entity
     - parameter alias:      Alias name to entity
     
     - returns: Self
     */
    public func join<T: ReflectProtocol>(type: T.Type, _ operation: Join = .Inner, foreignKey: String? = nil, _ comparison: Comparison = .Equals, otherKey: String? = nil ,alias:String = "" ) -> Self? {
        let fk = foreignKey ?? "\(entity).\(type.entityName())_objectId"
        let ok = otherKey ?? "\(type.entityName()).objectId"
        let union = Filter.Union(operation, type.entityName(), fk, comparison, ok)
        dataUnion.append(union)
        createFieldsAlias(type,alias: alias)
        return self
    }
    /**
     Sort Filter
     
     - parameter field:     Column name
     - parameter direction: Sort option
     
     - returns: Self
     */
    public func sort(field: String, _ direction: Sort) -> Self {
        let order = Filter.Order(field, direction)
        dataOrder.append(order)
        return self
    }
    /**
     Limit Filter
     
     - parameter count: value to quantity of results
     
     - returns: Self
     */
    public func limit(count: Int = 1) -> Self {
        dataPage.append(Pagination.Limit(count))
        return self
    }
    /**
     Offset Filter
     
     - parameter count: value to quantity of offset
     
     - returns: Self
     */
    public func offset(count: Int = 1) -> Self {
        dataPage.append(Pagination.Offset(count))
        return self
    }
    /**
     Distinct Filter
     
     - returns: Self
     */
    public func distinct() -> Self {
        dataDistinct = true
        return self
    }
    /**
     Count Object
     
     - parameter field: Column Name
     
     - returns: Quantity value found
     */
    public func count(field: String = "*") -> Double {
        dataAggregate = Aggregate.Count(field)
        return  convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Average Object
     
     - parameter field: Column Name
     
     - returns: Average of result
     */
    public func average(field: String = "*") -> Double {
        dataAggregate = Aggregate.Average(field)
        return convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Sum Object
     
     - parameter field: Column Name
     
     - returns: Sum of result
     */
    public func sum(field: String = "*") -> Double {
        dataAggregate = Aggregate.Sum(field)
        return convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Max Object
     
     - parameter field: Column Name
     
     - returns: Value max found
     */
    public func max(field: String = "*") -> Value {
        dataAggregate = Aggregate.Max(field)
        return aggregateObject(dataAggregate.field)!
    }
    /**
     Min Object
     
     - parameter field: Column Name
     
     - returns: Value min found
     */
    public func min(field: String = "*") -> Value {
        dataAggregate = Aggregate.Min(field)
        return aggregateObject(dataAggregate.field)!
    }
    
    /**
     Find Objects
     This method executa a query
     
     - returns: return Arry of Reflect Object
     */
    public func findObject() -> [T] {
        return try! Driver().find(self)
    }
}
// MARK: - Extension Query Private Methods
private extension Query {
    /**
     Resolve a criação do select
     
     - returns: return string contendo a instrução do Select
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
    /**
     Create Alias
     
     - parameter type:  Reflect Object
     - parameter alias: text it's optional
     */
    private func createFieldsAlias<T: ReflectProtocol>(type: T.Type, alias:String) {
        let properties = ReflectData.validPropertyDataForObject(type.init())
        let namespace  = alias.isEmpty ? type.entityName() : alias
        let columns = properties.map { value in
            return "\(namespace).\(value.name!) AS '\(namespace).\(value.name!)'"
        }
        dataFields += columns
    }
    /**
     Filter output - Resolve as intrução para o Where
     
     - parameter filter: Filter object
     
     - returns: return string value
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
        case .Union(let join, let entity, let fk, let comparison, let ok):
            return "\(join.description) \(entity) ON \(fk) \(comparison.description) \(ok)"
        }
    }
    /**
     Aggregate
     
     - parameter field: Column Name
     
     - returns: return value of query
     */
    private func aggregateObject(field:String) -> Value? {
        if let value = try! Driver().scalar(self, column: field) {
            return value
        }
        return nil
    }
    
    private func convertValueToDouble(value:Value?) -> Double {
    
        if let v = value as? Int64 {
            return Double(v)
        }
        else if let v = value as? Double {
            return v
        }
        else if let v = value as? Float {
            return Double(v)
        }
        
        return 0
    }
}