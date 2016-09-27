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
public class Query<T> where T:ReflectProtocol {
    /// Alias Handlee para clauses AND and OR
    public typealias Handler = (_ query: Query) -> Query
    /// Argumentos to Query
    open var dataArgs:[Value?]
    /// Distinct values
    fileprivate var dataDistinct :Bool
    /// Aggregate value (COUNT, SUM, MAX, MIN and AVG)
    fileprivate var dataAggregate:Aggregate
    /// Information to Fieds
    fileprivate var dataFields  :[String]
    /// Join beetween Reflect object
    fileprivate var dataUnion   :[Filter]
    /// Filters
    fileprivate var dataClause  :[Filter]
    /// Order by objects
    fileprivate var dataOrder   :[Filter]
    /// Limit and Offset
    fileprivate var dataPage    :[Pagination]
    /// Entity name
    fileprivate var entity: String {
        return T.entityName()
    }
    
    /// Statement Sql contem intrução sql and argumentos
    public var statement:(sql:String, args:[Value?]) {
        var query: [String] = [resolveSelect()]
        
        //JOIN
        if dataUnion.count > 0 {
            var filterUnion: [String] = []
            for filter in dataUnion {
                filterUnion.append(filterOutput(filter))
            }
            query.append(filterUnion.joined(separator: " "))
        }
        
        //Where
        if dataClause.count > 0 {
            var filterClause: [String] = []
            for filter in dataClause {
                filterClause.append(filterOutput(filter))
            }
            query.append("WHERE \(filterClause.joined(separator: " AND "))")
        }
        
        //Order by
        if dataOrder.count > 0 {
            query.append("ORDER BY")
            var filterOrder: [String] = []
            for order in dataOrder {
                filterOrder.append(filterOutput(order))
            }
            query.append(filterOrder.joined(separator: ", "))
        }
        
        //Limit and Offset
        for page in dataPage {
            query.append(page.description)
        }
        
        return ("\(query.joined(separator: " "));" , dataArgs)
    }
    /**
     Initialize Object
     
     */
    public init(){
        dataDistinct  = false
        dataAggregate = Aggregate.default
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
    @discardableResult
    public func fields(_ key:String...) -> Self {
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
    @discardableResult
    public func filter(_ key:String, _ comparison: Comparison, value:Value?...) -> Self {
        if value.count > 1 {
            dataClause.append(Filter.subset(key, comparison, value))
        }
        else{
            dataClause.append(Filter.compare(key, comparison, value.first!))
        }
        return self
    }
    /**
     Or Filter - Create an block  with condição OR para as confinações de filtro especifico with OR
     
     - parameter handler: Block Handler
     
     - returns: Self
     */
    @discardableResult
    public func or(_ handler: Handler) -> Self {
        let q = handler(Query())
        let filter = Filter.group(.or, q.dataClause)
        dataClause.append(filter)
        return self
    }
    /**
     And Filter -  Create an block with condição AND para as confinaç~eos de filtro especifico with OR
     
     - parameter handler: Block Handler
     
     - returns: Self
     */
    @discardableResult
    public func and(_ handler: Handler) -> Self {
        let q = handler(Query())
        let filter = Filter.group(.and, q.dataClause)
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
    @discardableResult
    public func join<T: ReflectProtocol>(_ type: T.Type, _ operation: Join = .inner, foreignKey: String? = nil, _ comparison: Comparison = .equals, otherKey: String? = nil ,alias:String = "" ) -> Self {
        let fk = foreignKey ?? "\(entity).\(type.entityName())_objectId"
        let ok = otherKey ?? "\(type.entityName()).objectId"
        let union = Filter.union(operation, type.entityName(), fk, comparison, ok)
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
    @discardableResult
    public func sort(_ field: String, _ direction: Sort) -> Self {
        let order = Filter.order(field, direction)
        dataOrder.append(order)
        return self
    }
    /**
     Limit Filter
     
     - parameter count: value to quantity of results
     
     - returns: Self
     */
    @discardableResult
    public func limit(_ count: Int = 1) -> Self {
        dataPage.append(Pagination.limit(count))
        return self
    }
    /**
     Offset Filter
     
     - parameter count: value to quantity of offset
     
     - returns: Self
     */
    @discardableResult
    public func offset(_ count: Int = 1) -> Self {
        dataPage.append(Pagination.offset(count))
        return self
    }
    /**
     Distinct Filter
     
     - returns: Self
     */
    @discardableResult
    public func distinct() -> Self {
        dataDistinct = true
        return self
    }
    /**
     Count Object
     
     - parameter field: Column Name
     
     - returns: Quantity value found
     */
    @discardableResult
    public func count(_ field: String = "*") -> Double {
        dataAggregate = Aggregate.count(field)
        return  convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Average Object
     
     - parameter field: Column Name
     
     - returns: Average of result
     */
    @discardableResult
    public func average(_ field: String = "*") -> Double {
        dataAggregate = Aggregate.average(field)
        return convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Sum Object
     
     - parameter field: Column Name
     
     - returns: Sum of result
     */
    @discardableResult
    public func sum(_ field: String = "*") -> Double {
        dataAggregate = Aggregate.sum(field)
        return convertValueToDouble(aggregateObject(dataAggregate.field))
    }
    /**
     Max Object
     
     - parameter field: Column Name
     
     - returns: Value max found
     */
    @discardableResult
    public func max(_ field: String = "*") -> Value {
        dataAggregate = Aggregate.max(field)
        return aggregateObject(dataAggregate.field)!
    }
    /**
     Min Object
     
     - parameter field: Column Name
     
     - returns: Value min found
     */
    @discardableResult
    public func min(_ field: String = "*") -> Value {
        dataAggregate = Aggregate.min(field)
        return aggregateObject(dataAggregate.field)!
    }
    
    /**
     Find Objects
     This method executa a query
     
     - returns: return Arry of Reflect Object
     */
    @discardableResult
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
    func resolveSelect() -> String {
        var select = ["SELECT"]
        if dataDistinct {
            select.append("DISTINCT")
        }
        
        if dataFields.count > 0 && dataAggregate.field == Aggregate.default.field {
            if dataUnion.count > 0 {
                dataFields.append("\(entity).*")
            }
            select.append(dataFields.joined(separator: ", "))
        } else {
            select.append(dataAggregate.description)
        }
        
        select.append("FROM \(entity)")
        
        return select.joined(separator: " ")
    }
    /**
     Create Alias
     
     - parameter type:  Reflect Object
     - parameter alias: text it's optional
     */
    func createFieldsAlias<T: ReflectProtocol>(_ type: T.Type, alias:String) {
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
    func filterOutput(_ filter: Filter) -> String {
        switch filter {
        case .compare(let field, let comparison, let value):
            if value == nil {
                return "\(field) \(comparison.description) NULL"
            }
            dataArgs.append(value)
            return "\(field) \(comparison.description) ?"
        case .subset(let field, let scope, let values):
            let valueDescriptions = values.map { value in
                dataArgs.append(value)
                return "?"
                }.joined(separator: scope == .between ? " AND " : " , ")
            return "\(field) \(scope.description) " + (scope == .between ? valueDescriptions : "(\(valueDescriptions))")
        case .group(let op, let filters):
            let f: [String] = filters.map {
                if case .group = $0 {
                    return self.filterOutput($0)
                }
                return "\(self.filterOutput($0))"
            }
            return "(" + f.joined(separator: " \(op.description) ") + ")"
        case .order(let field, let order):
            return "\(field) \(order)"
        case .union(let join, let entity, let fk, let comparison, let ok):
            return "\(join.description) \(entity) ON \(fk) \(comparison.description) \(ok)"
        }
    }
    /**
     Aggregate
     
     - parameter field: Column Name
     
     - returns: return value of query
     */
    func aggregateObject(_ field:String) -> Value? {
        if let value = try! Driver().scalar(self, column: field) {
            return value
        }
        return nil
    }
    
    func convertValueToDouble(_ value:Value?) -> Double {
    
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
