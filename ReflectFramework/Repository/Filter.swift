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
}

public enum Comparison: CustomStringConvertible{
    case Equals, GreaterThan, LessThan, NotEquals, In, NotIn, Is
    
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
