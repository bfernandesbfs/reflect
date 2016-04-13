//
//  Filter.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

public enum Filter {
    case Compare(String, Comparison, Value?)
    case Subset(String, Comparison, [Value?])
    case Group(Operation, [Filter])
    case Order(String, Sort)
    case Union(Join, String, String, Comparison, String)
}

public enum Comparison: CustomStringConvertible{
    case Equals, GreaterThan, LessThan, NotEquals, In, NotIn, Is, Like, NotLike ,Between
    
    public var description: String {
        switch self {
        case .Equals:
            return "="
        case .GreaterThan:
            return ">"
        case .LessThan:
            return "<"
        case .NotEquals:
            return "!="
        case .In:
            return "IN"
        case .NotIn:
            return "NOT IN"
        case .Is:
            return "IS"
        case .Like:
            return "LIKE"
        case .NotLike:
            return "NOT LIKE"
        case .Between:
            return "BETWEEN"
        }
    }
}

public enum Operation: CustomStringConvertible  {
    case And, Or
    
    public var description: String {
        switch self {
        case .And:
            return "AND"
        case .Or:
            return "OR"
        }
    }
}

public enum Join: CustomStringConvertible {
    case Inner, Right, Left
    
    public var description: String {
        switch self {
        case .Inner:
            return "INNER JOIN"
        case .Left:
            return "LEFT JOIN"
        case .Right:
            return "RIGHT JOIN"
        }
    }
}

public enum Sort: CustomStringConvertible  {
    case Asc, Desc
    
    public var description: String {
        switch self {
        case .Asc:
            return "ASC"
        case .Desc:
            return "DESC"
        }
    }
}

public enum Pagination: CustomStringConvertible  {
    case Limit(Int), Offset(Int)
    
    public var description: String {
        switch self {
        case .Limit(let count):
            return "LIMIT \(count)"
        case .Offset(let count):
            return "OFFSET \(count)"
        }
    }
}

public enum Aggregate: CustomStringConvertible  {
    case Default, Count(String), Average(String), Max(String), Min(String), Sum(String)
    
    public var description: String {
        switch self {
        case .Default:
            return "*"
        case .Count(let field):
            return "COUNT(\(field)) AS \(self.field)"
        case .Average(let field):
            return "AVG(\(field)) AS \(self.field)"
        case .Max(let field):
            return "MAX(\(field)) AS \(self.field)"
        case .Min(let field):
            return "MIN(\(field)) AS \(self.field)"
        case .Sum(let field):
            return "SUM(\(field)) AS \(self.field)"
        }
    }
    
    public var field: String {
        switch self {
        case .Default:
            return "default"
        case .Count:
            return "count"
        case .Average:
            return "average"
        case .Max:
            return "maximum"
        case .Min:
            return "minimum"
        case .Sum:
            return "value"
        }
    }
}
