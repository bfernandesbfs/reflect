//
//  Filter.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public enum Filter {
    case compare(String, Comparison, Value?)
    case subset(String, Comparison, [Value?])
    case group(Operation, [Filter])
    case order(String, Sort)
    case union(Join, String, String, Comparison, String)
}

public enum Comparison: CustomStringConvertible{
    case equals, greaterThan, lessThan, notEquals, `in`, notIn, `is`, like, notLike ,between
    
    public var description: String {
        switch self {
        case .equals:
            return "="
        case .greaterThan:
            return ">"
        case .lessThan:
            return "<"
        case .notEquals:
            return "!="
        case .in:
            return "IN"
        case .notIn:
            return "NOT IN"
        case .is:
            return "IS"
        case .like:
            return "LIKE"
        case .notLike:
            return "NOT LIKE"
        case .between:
            return "BETWEEN"
        }
    }
}

public enum Operation: CustomStringConvertible  {
    case and, or
    
    public var description: String {
        switch self {
        case .and:
            return "AND"
        case .or:
            return "OR"
        }
    }
}

public enum Join: CustomStringConvertible {
    case inner, right, left
    
    public var description: String {
        switch self {
        case .inner:
            return "INNER JOIN"
        case .left:
            return "LEFT JOIN"
        case .right:
            return "RIGHT JOIN"
        }
    }
}

public enum Sort: CustomStringConvertible  {
    case asc, desc
    
    public var description: String {
        switch self {
        case .asc:
            return "ASC"
        case .desc:
            return "DESC"
        }
    }
}

public enum Pagination: CustomStringConvertible  {
    case limit(Int), offset(Int)
    
    public var description: String {
        switch self {
        case .limit(let count):
            return "LIMIT \(count)"
        case .offset(let count):
            return "OFFSET \(count)"
        }
    }
}

public enum Aggregate: CustomStringConvertible  {
    case `default`, count(String), average(String), max(String), min(String), sum(String)
    
    public var description: String {
        switch self {
        case .default:
            return "*"
        case .count(let field):
            return "COUNT(\(field)) AS \(self.field)"
        case .average(let field):
            return "AVG(\(field)) AS \(self.field)"
        case .max(let field):
            return "MAX(\(field)) AS \(self.field)"
        case .min(let field):
            return "MIN(\(field)) AS \(self.field)"
        case .sum(let field):
            return "SUM(\(field)) AS \(self.field)"
        }
    }
    
    public var field: String {
        switch self {
        case .default:
            return "default"
        case .count:
            return "count"
        case .average:
            return "average"
        case .max:
            return "maximum"
        case .min:
            return "minimum"
        case .sum:
            return "value"
        }
    }
}
