//
//  Filter.swift
//  ReflectFramework
//
//  Created by Bruno Fernandes on 22/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

enum Filter {
    case Compare(String, Comparison, Value)
    case Subset(String, Comparison, [Value])
    case Group(Operation, [Filter])
}

enum Comparison: CustomStringConvertible{
    case Equals, GreaterThan, LessThan, NotEquals, In, NotIn
    
    var description: String {
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
        }
    }
}

enum Operation: CustomStringConvertible  {
    case And, Or
    
    var description: String {
        switch self {
        case .And:
            return "AND"
        case .Or:
            return "OR"
        }
    }
}

